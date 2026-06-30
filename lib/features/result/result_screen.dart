import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    // TODO: 结算页
    return Scaffold(
      body: Center(child: Text('得分: $score')),
    );
  }
}
