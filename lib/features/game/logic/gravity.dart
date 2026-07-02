import '../models/cell.dart';
import '../models/grid_position.dart';

/// 列内重力下落结果。
/// 记录每个格子从旧行移动到新行的映射，供下落动画使用。
class GravityResult {
  const GravityResult({
    required this.board,
    required this.moves,
  });

  final List<List<Cell>> board;

  /// key: "row,col" 旧坐标；value: 新 row。
  final Map<String, int> moves;
}

/// 对棋盘每一列执行重力：非空格下移填补底部，上方留空。
/// 返回更新后的棋盘以及位移动画所需的行变化映射。
GravityResult applyGravity(List<List<Cell>> board) {
  final int rowCount = board.length;
  if (rowCount == 0) {
    return GravityResult(board: board, moves: {});
  }
  final int colCount = board[0].length;
  final List<List<Cell>> newBoard = [];
  final Map<String, int> moves = {};

  for (int rowIndex = 0; rowIndex < rowCount; rowIndex = rowIndex + 1) {
    final List<Cell> newRow = [];
    for (int colIndex = 0; colIndex < colCount; colIndex = colIndex + 1) {
      newRow.add(
        Cell(row: rowIndex, col: colIndex, color: null),
      );
    }
    newBoard.add(newRow);
  }

  for (int colIndex = 0; colIndex < colCount; colIndex = colIndex + 1) {
    final List<Cell> columnCells = [];
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex = rowIndex + 1) {
      final Cell cell = board[rowIndex][colIndex];
      if (cell.color != null) {
        columnCells.add(cell);
      }
    }

    int writeRow = rowCount - 1;
    for (int i = columnCells.length - 1; i >= 0; i = i - 1) {
      final Cell oldCell = columnCells[i];
      final Cell newCell = Cell(
        row: writeRow,
        col: colIndex,
        color: oldCell.color,
      );
      newBoard[writeRow][colIndex] = newCell;

      if (oldCell.row != writeRow) {
        final String oldKey = '${oldCell.row},$colIndex';
        moves[oldKey] = writeRow;
      }

      writeRow = writeRow - 1;
    }
  }

  return GravityResult(board: newBoard, moves: moves);
}

/// 判断重力是否会引起格子位移（用于测试）。
bool hasGravityMoves(Map<String, int> moves) {
  return moves.isNotEmpty;
}

/// 将 GravityResult 中的 moves 转为 GridPosition 列表（调试用）。
List<GridPosition> gravityMovePositions(Map<String, int> moves) {
  final List<GridPosition> positions = [];
  for (final String key in moves.keys) {
    final List<String> parts = key.split(',');
    final int row = int.parse(parts[0]);
    final int col = int.parse(parts[1]);
    positions.add(GridPosition(row: row, col: col));
  }
  return positions;
}
