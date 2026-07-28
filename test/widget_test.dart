import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pop_star/main.dart';

void main() {
  testWidgets('首页显示游戏标题', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PopStarApp(),
      ),
    );

    // 跳过启动页，直接进入首页进行断言
    appRouter.go('/home');
    await tester.pumpAndSettle();

    expect(find.text('消灭星星'), findsOneWidget);
    expect(find.text('开始游戏'), findsOneWidget);
  });
}
