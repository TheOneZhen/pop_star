import 'cell.dart';
import 'game_status.dart';

class GameState {
  const GameState({
    required this.board,
    this.score = 0,
    this.status = GameStatus.playing,
  });

  final List<List<Cell>> board;
  final int score;
  final GameStatus status;
}
