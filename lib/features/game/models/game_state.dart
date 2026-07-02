import 'cell.dart';
import 'game_status.dart';

/// 游戏运行时状态模型。
/// 包含棋盘、当前分数与游戏阶段（playing / animating / gameOver）。
class GameState {
  const GameState({
    required this.board,
    this.score = 0,
    this.status = GameStatus.playing,
  });

  final List<List<Cell>> board;
  final int score;
  final GameStatus status;

  GameState copyWith({
    List<List<Cell>>? board,
    int? score,
    GameStatus? status,
  }) {
    return GameState(
      board: board ?? this.board,
      score: score ?? this.score,
      status: status ?? this.status,
    );
  }
}
