import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('消灭星星', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 48),
            _MenuButton(
              label: '开始游戏',
              onPressed: () {
                // TODO: 清除存档并跳转游戏页
              },
            ),
            const SizedBox(height: 16),
            const _ContinueGameButton(),
            const SizedBox(height: 16),
            _MenuButton(
              label: '排行榜',
              onPressed: () {
                // TODO: 跳转排行榜页
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 继续游戏：启动时读取本地存档，无存档则置灰
class _ContinueGameButton extends StatefulWidget {
  const _ContinueGameButton();

  @override
  State<_ContinueGameButton> createState() => _ContinueGameButtonState();
}

class _ContinueGameButtonState extends State<_ContinueGameButton> {
  final StorageService _storage = StorageService();

  bool _loading = true;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _loadContinueState();
  }

  Future<void> _loadContinueState() async {
    final canContinue = await _storage.hasSavedGame();
    if (!context.mounted) return;
    setState(() {
      _canContinue = canContinue;
      _loading = false;
    });
  }

  Future<void> _onContinuePressed() async {
    final game = await _storage.loadGame();
    if (!context.mounted || game == null) return;
    // TODO: 携带 game 跳转游戏页
  }

  @override
  Widget build(BuildContext context) {
    return _MenuButton(
      label: '继续游戏',
      onPressed: _loading || !_canContinue ? null : _onContinuePressed,
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
