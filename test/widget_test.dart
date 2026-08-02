import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pop_star/main.dart';

void main() {
  testWidgets('底部菜单与首页显示正常', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PopStarApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    expect(find.text('列表'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('this is home page!'), findsOneWidget);
  });
}
