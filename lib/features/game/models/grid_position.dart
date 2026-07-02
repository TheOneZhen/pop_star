/// 棋盘格子坐标模型。
/// 使用显式类表示行列位置，替代 Dart Record 语法糖，便于比较与调试。
class GridPosition {
  const GridPosition({required this.row, required this.col});

  final int row;
  final int col;

  String get key {
    return '$row,$col';
  }

  @override
  bool operator ==(Object other) {
    if (other is! GridPosition) {
      return false;
    }
    if (row != other.row) {
      return false;
    }
    if (col != other.col) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(row, col);
  }
}
