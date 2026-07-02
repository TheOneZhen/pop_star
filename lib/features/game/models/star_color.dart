import 'package:flutter/material.dart';

/// 星星方块颜色枚举。
/// 提供与 Flutter Color 的显式映射，供棋盘渲染使用。
enum StarColor {
  red,
  green,
  blue,
  yellow,
  purple,
  orange,
}

extension StarColorDisplay on StarColor {
  Color toColor() {
    switch (this) {
      case StarColor.red:
        return const Color(0xFFE53935);
      case StarColor.green:
        return const Color(0xFF43A047);
      case StarColor.blue:
        return const Color(0xFF1E88E5);
      case StarColor.yellow:
        return const Color(0xFFFDD835);
      case StarColor.purple:
        return const Color(0xFF8E24AA);
      case StarColor.orange:
        return const Color(0xFFFB8C00);
    }
  }
}
