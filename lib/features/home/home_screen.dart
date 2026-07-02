import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final StorageService _storage = StorageService();

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
              onPressed: () async {
                await _storage.clearSavedGame(); // 先清档
                if (!context.mounted) return;
                context.go('/game'); // 再跳转游戏页（游戏页内部会根据是否存在档案来判断是新游戏还是继续游戏）
              },
            ),
            const SizedBox(height: 16),
            const _ContinueGameButton(), // 继续游戏
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
    if (!mounted) return;
    setState(() {
      _canContinue = canContinue;
      _loading = false;
    });
  }

  Future<void> _onContinuePressed() async {
    final game = await _storage.loadGame();
    if (game == null || !mounted) return;
    context.go('/game/continue');
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
