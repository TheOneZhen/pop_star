import 'package:flutter/material.dart';

import 'widgets/page_scaffold.dart';

/// 首页 Tab。
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: '首页',
      subtitle: 'this is home page!',
      colors: [
        Color(0xFF1A237E),
        Color(0xFF4A148C),
        Color(0xFF880E4F),
      ],
    );
  }
}
