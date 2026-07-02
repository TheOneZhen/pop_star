import 'package:flutter/material.dart';

import '../models/star_color.dart';

/// 单个星星方块 Widget：圆角色块、高亮边框与缩放/透明度动画支持。
class StarCell extends StatelessWidget {
  const StarCell({
    super.key,
    required this.color,
    required this.size,
    this.isHighlighted = false,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.onTap,
  });

  final StarColor? color;
  final double size;
  final bool isHighlighted;
  final double scale;
  final double opacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (color == null) {
      return SizedBox(width: size, height: size);
    }

    final Color blockColor = color!.toColor();
    Widget cellContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: blockColor,
        borderRadius: BorderRadius.circular(size * 0.18),
        border: isHighlighted
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: blockColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            blockColor.withValues(alpha: 0.95),
            blockColor.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.star,
          color: Colors.white.withValues(alpha: 0.85),
          size: size * 0.45,
        ),
      ),
    );

    cellContent = Opacity(opacity: opacity, child: cellContent);
    cellContent = Transform.scale(scale: scale, child: cellContent);

    if (onTap != null) {
      cellContent = GestureDetector(
        onTap: onTap,
        child: cellContent,
      );
    }

    return cellContent;
  }
}
