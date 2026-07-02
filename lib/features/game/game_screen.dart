import 'package:flutter/material.dart';
import 'package:pop_star/services/storage_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('GameScreen')));
  }
}
