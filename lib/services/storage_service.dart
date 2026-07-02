import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/game/models/cell.dart';
import '../features/game/models/game_state.dart';
import '../features/game/models/game_status.dart';
import '../features/game/models/star_color.dart';

/// 本地存档：游戏进度、最高分、设置等
class StorageService {
  static const _savedGameKey = 'saved_game';
  static const _highScoreKey = 'high_score';
  static const _soundEnabledKey = 'sound_enabled';
  static const _vibrationEnabledKey = 'vibration_enabled';
  static const leaderboardMaxEntries = 10;

  /// 是否存在可继续的进行中存档
  Future<bool> hasSavedGame() async {
    final game = await loadGame();
    if (game == null) return false;
    return game.status == GameStatus.playing ||
        game.status == GameStatus.animating;
  }

  Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedGameKey, jsonEncode(_encodeGameState(state)));
  }

  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedGameKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _decodeGameState(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Map<String, dynamic> _encodeGameState(GameState state) {
    return {
      'score': state.score,
      'status': state.status.name,
      'board': state.board
          .map((row) => row.map((cell) => cell.color?.name).toList())
          .toList(),
    };
  }

  GameState _decodeGameState(Map<String, dynamic> json) {
    final boardJson = json['board'] as List<dynamic>;
    final board = <List<Cell>>[];

    for (var rowIndex = 0; rowIndex < boardJson.length; rowIndex++) {
      final row = boardJson[rowIndex] as List<dynamic>;
      board.add([
        for (var colIndex = 0; colIndex < row.length; colIndex++)
          Cell(
            row: rowIndex,
            col: colIndex,
            color: _parseColor(row[colIndex] as String?),
          ),
      ]);
    }

    return GameState(
      board: board,
      score: json['score'] as int? ?? 0,
      status: GameStatus.values.byName(json['status'] as String? ?? 'playing'),
    );
  }

  StarColor? _parseColor(String? name) {
    if (name == null) return null;
    return StarColor.values.byName(name);
  }
}
