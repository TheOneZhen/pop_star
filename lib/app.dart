import 'package:flutter/material.dart';

/// 应用根组件：MaterialApp + 路由（后续接入 go_router）
class PopStarApp extends StatelessWidget {
  const PopStarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '消灭星星',
      home: const Scaffold(
        body: Center(child: Text('消灭星星')),
      ),
    );
  }
}
