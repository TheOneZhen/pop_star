import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/game/models/cell.dart';
import '../features/game/models/game_state.dart';
import '../features/game/models/game_status.dart';
import '../features/game/models/star_color.dart';

/// 本地持久化服务：中途存档、最高分、音效与震动设置。
/// 基于 SharedPreferences，所有读写均通过显式方法封装。
class StorageService {
  static const String savedGameKey = 'saved_game';
  static const String highScoreKey = 'high_score';
  static const String soundEnabledKey = 'sound_enabled';
  static const String vibrationEnabledKey = 'vibration_enabled';

  Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  /// 是否存在可继续的进行中存档。
  Future<bool> hasSavedGame() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(savedGameKey);
    if (raw == null) {
      return false;
    }
    if (raw.isEmpty) {
      return false;
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      final String? status = json['status'] as String?;
      if (status == GameStatus.playing.name) {
        return true;
      }
      if (status == GameStatus.animating.name) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveGame(GameState state) async {
    final SharedPreferences prefs = await _prefs();
    final String encoded = jsonEncode(_encodeGameState(state));
    await prefs.setString(savedGameKey, encoded);
  }

  Future<GameState?> loadGame() async {
    final SharedPreferences prefs = await _prefs();
    final String? raw = prefs.getString(savedGameKey);
    if (raw == null) {
      return null;
    }
    if (raw.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;
      return _decodeGameState(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedGame() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(savedGameKey);
  }

  Future<int> getHighScore() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getInt(highScoreKey) ?? 0;
  }

  Future<void> setHighScore(int score) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setInt(highScoreKey, score);
  }

  /// 若本局分数更高则更新最高分，返回是否破纪录。
  Future<bool> updateHighScoreIfNeeded(int score) async {
    final int currentHigh = await getHighScore();
    if (score > currentHigh) {
      await setHighScore(score);
      return true;
    }
    return false;
  }

  Future<bool> getSoundEnabled() async {
    final SharedPreferences prefs = await _prefs();
    if (!prefs.containsKey(soundEnabledKey)) {
      return true;
    }
    return prefs.getBool(soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setBool(soundEnabledKey, enabled);
  }

  Future<bool> getVibrationEnabled() async {
    final SharedPreferences prefs = await _prefs();
    if (!prefs.containsKey(vibrationEnabledKey)) {
      return true;
    }
    return prefs.getBool(vibrationEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setBool(vibrationEnabledKey, enabled);
  }

  Map<String, dynamic> _encodeGameState(GameState state) {
    final List<List<String?>> boardData = [];
    for (int row = 0; row < state.board.length; row = row + 1) {
      final List<String?> rowData = [];
      for (int col = 0; col < state.board[row].length; col = col + 1) {
        final StarColor? color = state.board[row][col].color;
        if (color == null) {
          rowData.add(null);
        } else {
          rowData.add(color.name);
        }
      }
      boardData.add(rowData);
    }

    return {
      'score': state.score,
      'status': state.status.name,
      'board': boardData,
    };
  }

  GameState _decodeGameState(Map<String, dynamic> json) {
    final List<dynamic> boardJson = json['board'] as List<dynamic>;
    final List<List<Cell>> board = [];

    for (int rowIndex = 0; rowIndex < boardJson.length; rowIndex = rowIndex + 1) {
      final List<dynamic> rowJson = boardJson[rowIndex] as List<dynamic>;
      final List<Cell> row = [];
      for (int colIndex = 0; colIndex < rowJson.length; colIndex = colIndex + 1) {
        final String? colorName = rowJson[colIndex] as String?;
        row.add(
          Cell(
            row: rowIndex,
            col: colIndex,
            color: _parseColor(colorName),
          ),
        );
      }
      board.add(row);
    }

    final String statusName = json['status'] as String? ?? 'playing';
    return GameState(
      board: board,
      score: json['score'] as int? ?? 0,
      status: GameStatus.values.byName(statusName),
    );
  }

  StarColor? _parseColor(String? name) {
    if (name == null) {
      return null;
    }
    return StarColor.values.byName(name);
  }
}
