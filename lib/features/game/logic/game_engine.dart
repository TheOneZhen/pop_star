import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../models/cell.dart';
import '../models/eliminate_result.dart';
import '../models/game_state.dart';
import '../models/game_status.dart';
import '../models/grid_position.dart';
import '../models/star_color.dart';
import 'flood_fill.dart';
import 'gravity.dart';

/// 游戏核心引擎：负责棋盘初始化、点击消除、重力、计分与死局检测。
/// 纯 Dart 类，不依赖 Flutter Widget，便于单元测试。
class GameEngine {
  GameState state = const GameState(board: []);
  final Random _random = Random();

  /// 最近一次重力下落的位移动画映射（key: "oldRow,col", value: newRow）。
  Map<String, int> lastGravityMoves = {};

  void newGame({
    int rows = GameConstants.defaultRows,
    int cols = GameConstants.defaultCols,
    int colorCount = GameConstants.defaultColorCount,
  }) {
    List<List<Cell>> board = [];
    int retry = 0;

    while (retry < GameConstants.maxBoardGenerationRetries) {
      board = _createRandomBoard(rows, cols, colorCount);
      state = GameState(board: board, score: 0, status: GameStatus.playing);
      if (hasValidMove()) {
        return;
      }
      retry = retry + 1;
    }

    state = GameState(board: board, score: 0, status: GameStatus.playing);
  }

  /// 使用指定颜色矩阵初始化棋盘（主要用于单元测试）。
  void loadBoard(List<List<StarColor?>> colors, {int score = 0}) {
    final List<List<Cell>> board = [];
    for (int row = 0; row < colors.length; row = row + 1) {
      final List<Cell> rowCells = [];
      for (int col = 0; col < colors[row].length; col = col + 1) {
        rowCells.add(Cell(row: row, col: col, color: colors[row][col]));
      }
      board.add(rowCells);
    }
    state = GameState(board: board, score: score, status: GameStatus.playing);
  }

  /// 点击格子尝试消除。连通数小于 2 时返回 null。
  EliminateResult? tap(int row, int col) {
    if (state.status != GameStatus.playing) {
      return null;
    }

    final List<GridPosition> connected = floodFill(state.board, row, col);
    if (connected.length < 2) {
      return null;
    }

    final StarColor? eliminatedColor = state.board[row][col].color;
    if (eliminatedColor == null) {
      return null;
    }

    final List<List<Cell>> newBoard = _copyBoard(state.board);
    for (int i = 0; i < connected.length; i = i + 1) {
      final GridPosition position = connected[i];
      final Cell oldCell = newBoard[position.row][position.col];
      newBoard[position.row][position.col] = Cell(
        row: oldCell.row,
        col: oldCell.col,
        color: null,
      );
    }

    final int scoreDelta = calcScore(connected.length);
    state = state.copyWith(
      board: newBoard,
      score: state.score + scoreDelta,
    );

    return EliminateResult(
      positions: connected,
      scoreDelta: scoreDelta,
      color: eliminatedColor,
    );
  }

  /// 执行重力下落并更新棋盘状态。
  void applyGravityToBoard() {
    final GravityResult result = applyGravity(state.board);
    lastGravityMoves = result.moves;
    state = state.copyWith(board: result.board);
  }

  /// 检测是否仍存在可消除的连通块（至少 2 个同色相邻）。
  bool hasValidMove() {
    final int rowCount = state.board.length;
    if (rowCount == 0) {
      return false;
    }
    final int colCount = state.board[0].length;

    for (int row = 0; row < rowCount; row = row + 1) {
      for (int col = 0; col < colCount; col = col + 1) {
        final Cell cell = state.board[row][col];
        if (cell.color == null) {
          continue;
        }
        final List<GridPosition> connected = floodFill(state.board, row, col);
        if (connected.length >= 2) {
          return true;
        }
      }
    }

    return false;
  }

  int calcScore(int eliminatedCount) {
    return GameConstants.scoreForCount(eliminatedCount);
  }

  void setStatus(GameStatus status) {
    state = state.copyWith(status: status);
  }

  List<List<Cell>> _createRandomBoard(int rows, int cols, int colorCount) {
    final List<StarColor> palette = [];
    for (int i = 0; i < colorCount && i < StarColor.values.length; i = i + 1) {
      palette.add(StarColor.values[i]);
    }

    final List<List<Cell>> board = [];
    for (int row = 0; row < rows; row = row + 1) {
      final List<Cell> rowCells = [];
      for (int col = 0; col < cols; col = col + 1) {
        final int colorIndex = _random.nextInt(palette.length);
        rowCells.add(
          Cell(row: row, col: col, color: palette[colorIndex]),
        );
      }
      board.add(rowCells);
    }
    return board;
  }

  List<List<Cell>> _copyBoard(List<List<Cell>> board) {
    final List<List<Cell>> copy = [];
    for (int row = 0; row < board.length; row = row + 1) {
      final List<Cell> rowCopy = [];
      for (int col = 0; col < board[row].length; col = col + 1) {
        final Cell cell = board[row][col];
        rowCopy.add(Cell(row: cell.row, col: cell.col, color: cell.color));
      }
      copy.add(rowCopy);
    }
    return copy;
  }
}
