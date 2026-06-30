import 'star_color.dart';

class Cell {
  const Cell({
    required this.row,
    required this.col,
    this.color,
  });

  final int row;
  final int col;
  final StarColor? color;
}
