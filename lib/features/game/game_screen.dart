import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../home/home_screen.dart';
import '../../services/storage_service.dart';
import 'models/animation_phase.dart';
import 'models/game_status.dart';
import 'providers/game_notifier.dart';
import 'widgets/board_widget.dart';

/// 游戏主界面：分数栏、棋盘、重玩/返回，以及游戏结束结算弹窗。
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.continueGame});

  /// true 表示从存档继续，false 表示新游戏。
  final bool continueGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _initialized = false;
  bool _gameOverDialogShown = false;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGame();
    });
  }

  Future<void> _initGame() async {
    final GameNotifier notifier = ref.read(gameNotifierProvider.notifier);
    if (widget.continueGame) {
      await notifier.continueFromStorage();
    } else {
      await notifier.startNewGame();
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _initialized = true;
    });
  }

  Future<void> _showGameOverDialog() async {
    if (_gameOverDialogShown) {
      return;
    }
    _gameOverDialogShown = true;

    final int score = ref.read(gameNotifierProvider).gameState.score;
    final bool isNewRecord = ref.read(gameNotifierProvider).isNewRecord;
    final int highScore = await _storage.getHighScore();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('游戏结束'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('本局得分: $score'),
              Text('最高分: $highScore'),
              if (isNewRecord)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '恭喜破纪录！',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/');
              },
              child: const Text('返回首页'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _gameOverDialogShown = false;
                await ref.read(gameNotifierProvider.notifier).restartGame();
              },
              child: const Text('再来一局'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameNotifierProvider, (previous, next) {
      if (next.gameState.status == GameStatus.gameOver) {
        _showGameOverDialog();
      }
    });

    final session = ref.watch(gameNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: AppBackground.decoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '得分: ${session.gameState.score}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await ref
                                .read(gameNotifierProvider.notifier)
                                .restartGame();
                            _gameOverDialogShown = false;
                          },
                          child: const Text('重玩'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/');
                          },
                          child: const Text('首页'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: _initialized
                        ? const BoardWidget()
                        : const CircularProgressIndicator(),
                  ),
                ),
                if (session.animationPhase != AnimationPhase.none)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '动画中...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
