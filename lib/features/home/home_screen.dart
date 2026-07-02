import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/storage_service.dart';

/// 游戏首页：展示标题、最高分、开始/继续游戏与设置入口。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppBackground.decoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '消灭星星',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<int>(
                future: _storage.getHighScore(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  final int highScore = snapshot.data ?? 0;
                  return Text(
                    '最高分: $highScore',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  );
                },
              ),
              const SizedBox(height: 48),
              _MenuButton(
                label: '开始游戏',
                onPressed: () async {
                  await _storage.clearSavedGame();
                  if (!context.mounted) {
                    return;
                  }
                  context.go('/game');
                },
              ),
              const SizedBox(height: 16),
              const _ContinueGameButton(),
              const SizedBox(height: 16),
              _MenuButton(
                label: '设置',
                onPressed: () {
                  context.go('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 继续游戏按钮：无存档时禁用。
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
    final bool canContinue = await _storage.hasSavedGame();
    if (!mounted) {
      return;
    }
    setState(() {
      _canContinue = canContinue;
      _loading = false;
    });
  }

  void _onContinuePressed() {
    context.go('/game/continue');
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback? onPressed;
    if (!_loading && _canContinue) {
      onPressed = _onContinuePressed;
    }

    return _MenuButton(
      label: '继续游戏',
      onPressed: onPressed,
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
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

/// 首页与游戏页共用的渐变背景装饰。
class AppBackground {
  AppBackground._();

  static BoxDecoration get decoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A237E), Color(0xFF311B92)],
      ),
    );
  }
}
