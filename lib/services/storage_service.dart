import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/game/models/cell.dart';
import '../features/game/models/game_state.dart';
import '../features/game/models/game_status.dart';
import '../features/game/models/star_color.dart';

/// 本地游戏存档
class StorageService {
  static const _savedGameKey = 'saved_game';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  /// 是否存在可继续的进行中存档
  Future<bool> hasSavedGame() async {
    final raw = (await _prefs()).getString(_savedGameKey);
    if (raw == null || raw.isEmpty) return false;

    try {
      final status =
          (jsonDecode(raw) as Map<String, dynamic>)['status'] as String?;
      return status == GameStatus.playing.name ||
          status == GameStatus.animating.name;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveGame(GameState state) async {
    final prefs = await _prefs();
    await prefs.setString(_savedGameKey, jsonEncode(_encodeGameState(state)));
  }

  Future<GameState?> loadGame() async {
    final raw = (await _prefs()).getString(_savedGameKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return _decodeGameState(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavedGame() async {
    final prefs = await _prefs();
    await prefs.remove(_savedGameKey);
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
    final board = [
      for (var rowIndex = 0; rowIndex < boardJson.length; rowIndex++)
        [
          for (var colIndex = 0; colIndex < (boardJson[rowIndex] as List).length;
              colIndex++)
            Cell(
              row: rowIndex,
              col: colIndex,
              color: _parseColor(
                (boardJson[rowIndex] as List)[colIndex] as String?,
              ),
            ),
        ],
    ];

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
