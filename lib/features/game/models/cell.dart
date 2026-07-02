import 'star_color.dart';

/// 棋盘单个格子模型。
/// color 为 null 时表示该格已被消除（空格）。
class Cell {
  const Cell({
    required this.row,
    required this.col,
    this.color,
  });

  final int row;
  final int col;
  final StarColor? color;

  Cell copyWith({
    int? row,
    int? col,
    StarColor? color,
    bool clearColor = false,
  }) {
    StarColor? newColor = this.color;
    if (clearColor) {
      newColor = null;
    } else if (color != null) {
      newColor = color;
    }

    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      color: newColor,
    );
  }
}
