import '../models/game_state.dart';

class GameEngine {
  GameState state = const GameState(board: []);

  void newGame({int rows = 10, int cols = 10, int colorCount = 5}) {
    // TODO: 初始化棋盘
  }

  // TODO: tap, applyGravity, hasValidMove, calcScore
}
