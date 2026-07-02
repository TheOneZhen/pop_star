import '../models/cell.dart';
import '../models/grid_position.dart';
import '../models/star_color.dart';

/// 连通块检测（Flood Fill / BFS）。
/// 从指定格子出发，四方向扩展同色相邻格，返回连通区域坐标列表。
List<GridPosition> floodFill(
  List<List<Cell>> board,
  int row,
  int col,
) {
  final List<GridPosition> result = [];
  final int rowCount = board.length;
  if (rowCount == 0) {
    return result;
  }
  final int colCount = board[0].length;

  if (row < 0 || row >= rowCount) {
    return result;
  }
  if (col < 0 || col >= colCount) {
    return result;
  }

  final Cell startCell = board[row][col];
  if (startCell.color == null) {
    return result;
  }

  final StarColor targetColor = startCell.color!;
  final Set<String> visited = {};
  final List<GridPosition> queue = [];

  queue.add(GridPosition(row: row, col: col));
  visited.add('$row,$col');

  int index = 0;
  while (index < queue.length) {
    final GridPosition current = queue[index];
    index = index + 1;
    result.add(current);

    final List<GridPosition> neighbors = [
      GridPosition(row: current.row - 1, col: current.col),
      GridPosition(row: current.row + 1, col: current.col),
      GridPosition(row: current.row, col: current.col - 1),
      GridPosition(row: current.row, col: current.col + 1),
    ];

    for (int i = 0; i < neighbors.length; i = i + 1) {
      final GridPosition neighbor = neighbors[i];
      if (neighbor.row < 0 || neighbor.row >= rowCount) {
        continue;
      }
      if (neighbor.col < 0 || neighbor.col >= colCount) {
        continue;
      }

      final String neighborKey = neighbor.key;
      if (visited.contains(neighborKey)) {
        continue;
      }

      final Cell neighborCell = board[neighbor.row][neighbor.col];
      if (neighborCell.color != targetColor) {
        continue;
      }

      visited.add(neighborKey);
      queue.add(neighbor);
    }
  }

  return result;
}

/// 根据颜色在棋盘上查找连通块（供死局检测使用）。
List<GridPosition> floodFillBoard(List<List<Cell>> board, int row, int col) {
  return floodFill(board, row, col);
}
