import 'package:flutter_test/flutter_test.dart';
import 'package:pop_star/features/game/logic/game_engine.dart';
import 'package:pop_star/features/game/logic/gravity.dart';
import 'package:pop_star/features/game/models/cell.dart';
import 'package:pop_star/features/game/models/eliminate_result.dart';
import 'package:pop_star/features/game/models/star_color.dart';

void main() {
  group('GameEngine', () {
    test('两个相邻同色块可以消除', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.red, StarColor.red, StarColor.blue],
        [StarColor.blue, StarColor.green, StarColor.green],
      ]);

      final EliminateResult? result = engine.tap(0, 0);

      expect(result, isNotNull);
      expect(result!.positions.length, 2);
      expect(result.scoreDelta, 10);
      expect(engine.state.score, 10);
      expect(engine.state.board[0][0].color, isNull);
      expect(engine.state.board[0][1].color, isNull);
    });

    test('单个孤立块不能消除', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.red, StarColor.blue],
        [StarColor.green, StarColor.yellow],
      ]);

      final EliminateResult? result = engine.tap(0, 0);

      expect(result, isNull);
      expect(engine.state.score, 0);
      expect(engine.state.board[0][0].color, StarColor.red);
    });

    test('消除后重力使方块下落', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.blue, StarColor.green, StarColor.orange],
        [null, StarColor.yellow, StarColor.purple],
        [StarColor.red, StarColor.red, StarColor.orange],
      ]);

      engine.tap(2, 0);
      engine.applyGravityToBoard();

      expect(engine.state.board[2][0].color, StarColor.blue);
      expect(engine.state.board[2][1].color, StarColor.yellow);
      expect(engine.state.board[1][2].color, StarColor.purple);
      expect(engine.state.board[2][2].color, StarColor.orange);
      expect(engine.state.board[0][0].color, isNull);
      expect(engine.state.board[1][0].color, isNull);
    });

    test('计分公式正确', () {
      final GameEngine engine = GameEngine();

      expect(engine.calcScore(2), 10);
      expect(engine.calcScore(3), 30);
      expect(engine.calcScore(5), 100);
      expect(engine.calcScore(10), 450);
    });

    test('死局检测：无可消除组合时返回 false', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.red, StarColor.blue, StarColor.green],
        [StarColor.yellow, StarColor.purple, StarColor.orange],
        [StarColor.blue, StarColor.red, StarColor.yellow],
      ]);

      expect(engine.hasValidMove(), isFalse);
    });

    test('死局检测：存在可消除组合时返回 true', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.red, StarColor.red, StarColor.green],
        [StarColor.yellow, StarColor.purple, StarColor.orange],
      ]);

      expect(engine.hasValidMove(), isTrue);
    });

    test('随机开局棋盘存在合法步', () {
      final GameEngine engine = GameEngine();
      engine.newGame(rows: 10, cols: 10, colorCount: 5);

      expect(engine.state.board.length, 10);
      expect(engine.state.board[0].length, 10);
      expect(engine.hasValidMove(), isTrue);
    });

    test('点击空格无效', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [null, StarColor.red],
        [StarColor.red, StarColor.blue],
      ]);

      final EliminateResult? result = engine.tap(0, 0);

      expect(result, isNull);
    });

    test('大面积连通块消除得分更高', () {
      final GameEngine engine = GameEngine();
      engine.loadBoard([
        [StarColor.red, StarColor.red, StarColor.red],
        [StarColor.red, StarColor.blue, StarColor.blue],
      ]);

      final EliminateResult? result = engine.tap(0, 0);

      expect(result, isNotNull);
      expect(result!.positions.length, 4);
      expect(result.scoreDelta, 60);
    });
  });

  group('applyGravity', () {
    test('整列下落到底部', () {
      final List<List<StarColor?>> raw = [
        [StarColor.red, StarColor.blue],
        [null, StarColor.green],
        [null, null],
      ];

      final List<List<Cell>> board = _toCells(raw);
      final GravityResult result = applyGravity(board);

      expect(result.board[2][0].color, StarColor.red);
      expect(result.board[1][0].color, isNull);
      expect(result.board[0][0].color, isNull);
      expect(result.board[2][1].color, StarColor.green);
      expect(result.board[1][1].color, StarColor.blue);
    });
  });
}

List<List<Cell>> _toCells(List<List<StarColor?>> raw) {
  final List<List<Cell>> board = [];
  for (int row = 0; row < raw.length; row = row + 1) {
    final List<Cell> rowCells = [];
    for (int col = 0; col < raw[row].length; col = col + 1) {
      rowCells.add(Cell(row: row, col: col, color: raw[row][col]));
    }
    board.add(rowCells);
  }
  return board;
}
