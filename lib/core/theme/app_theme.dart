import 'package:flutter/material.dart';

/// 应用主题：深蓝紫渐变背景与 Material 3 配色。
class AppTheme {
  AppTheme._();

  static const Color backgroundTop = Color(0xFF1A237E);
  static const Color backgroundBottom = Color(0xFF311B92);
  static const Color boardBackground = Color(0xFF0D1B3E);

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundTop,
    );
  }

  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [backgroundTop, backgroundBottom],
      ),
    );
  }
}
