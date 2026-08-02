import 'package:flutter/material.dart';

import 'widgets/page_scaffold.dart';

/// 列表 Tab。
class TablePage extends StatelessWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: '列表',
      subtitle: 'this is table page!',
      colors: [
        Color(0xFF004D40),
        Color(0xFF00695C),
        Color(0xFF0277BD),
      ],
    );
  }
}
