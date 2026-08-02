import 'package:flutter/material.dart';

import 'widgets/page_scaffold.dart';

/// 我的 Tab。
class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: '我的',
      subtitle: 'this is profile page!',
      colors: [
        Color(0xFF311B92),
        Color(0xFF512DA8),
        Color(0xFF7B1FA2),
      ],
    );
  }
}
