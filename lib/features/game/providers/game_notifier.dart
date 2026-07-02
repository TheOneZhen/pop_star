import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/storage_service.dart';
import '../logic/flood_fill.dart';
import '../logic/game_engine.dart';
import '../models/animation_phase.dart';
import '../models/eliminate_result.dart';
import '../models/game_session_state.dart';
import '../models/game_state.dart';
import '../models/game_status.dart';
import '../models/grid_position.dart';

/// 游戏状态管理器：封装 GameEngine 与动画状态机，负责存档同步。
class GameNotifier extends StateNotifier<GameSessionState> {
  GameNotifier(this._storage)
      : super(
          GameSessionState(
            gameState: const GameState(board: []),
          ),
        );

  final StorageService _storage;
  final GameEngine _engine = GameEngine();

  GameEngine get engine {
    return _engine;
  }

  Future<void> startNewGame() async {
    _engine.newGame();
    state = GameSessionState(
      gameState: _engine.state,
      animationPhase: AnimationPhase.none,
      highlightedPositions: [],
    );
    await _persistIfNeeded();
  }

  Future<void> loadSavedGame(GameState saved) async {
    _engine.state = saved.copyWith(status: GameStatus.playing);
    state = GameSessionState(
      gameState: _engine.state,
      animationPhase: AnimationPhase.none,
      highlightedPositions: [],
    );
    await _persistIfNeeded();
  }

  Future<void> continueFromStorage() async {
    final GameState? saved = await _storage.loadGame();
    if (saved == null) {
      await startNewGame();
      return;
    }
    await loadSavedGame(saved);
  }

  /// 点击格子：有效则进入消除动画阶段。
  EliminateResult? onCellTap(int row, int col) {
    if (state.gameState.status != GameStatus.playing) {
      return null;
    }
    if (state.animationPhase != AnimationPhase.none) {
      return null;
    }

    final EliminateResult? result = _engine.tap(row, col);
    if (result == null) {
      return null;
    }

    _engine.setStatus(GameStatus.animating);
    state = state.copyWith(
      gameState: _engine.state,
      animationPhase: AnimationPhase.eliminating,
      lastEliminate: result,
      highlightedPositions: [],
    );
    return result;
  }

  /// 预览连通块（手指按下时高亮，可选交互增强）。
  void previewCell(int row, int col) {
    if (state.gameState.status != GameStatus.playing) {
      return;
    }
    if (state.animationPhase != AnimationPhase.none) {
      return;
    }

    final List<GridPosition> connected =
        floodFill(state.gameState.board, row, col);
    if (connected.length < 2) {
      state = state.copyWith(highlightedPositions: []);
      return;
    }

    state = state.copyWith(highlightedPositions: connected);
  }

  void clearPreview() {
    state = state.copyWith(highlightedPositions: []);
  }

  /// 消除动画结束后：执行重力并进入下落动画阶段。
  Future<void> finishEliminateAnimation() async {
    if (state.animationPhase != AnimationPhase.eliminating) {
      return;
    }

    _engine.applyGravityToBoard();
    state = state.copyWith(
      gameState: _engine.state,
      animationPhase: AnimationPhase.gravity,
      gravityMoves: _engine.lastGravityMoves,
      clearLastEliminate: true,
    );
  }

  /// 下落动画结束后：检测死局或恢复 playing。
  Future<void> finishGravityAnimation() async {
    if (state.animationPhase != AnimationPhase.gravity) {
      return;
    }

    if (_engine.hasValidMove()) {
      _engine.setStatus(GameStatus.playing);
      state = state.copyWith(
        gameState: _engine.state,
        animationPhase: AnimationPhase.none,
        gravityMoves: {},
      );
      await _persistIfNeeded();
      return;
    }

    _engine.setStatus(GameStatus.gameOver);
    final bool isNewRecord =
        await _storage.updateHighScoreIfNeeded(_engine.state.score);
    await _storage.clearSavedGame();

    state = state.copyWith(
      gameState: _engine.state,
      animationPhase: AnimationPhase.none,
      gravityMoves: {},
      isNewRecord: isNewRecord,
    );
  }

  Future<void> restartGame() async {
    await startNewGame();
  }

  Future<void> _persistIfNeeded() async {
    if (_engine.state.status == GameStatus.playing) {
      await _storage.saveGame(_engine.state);
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameSessionState>((ref) {
  final StorageService storage = ref.watch(storageServiceProvider);
  return GameNotifier(storage);
});
