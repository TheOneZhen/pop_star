import 'package:flutter/material.dart';

import '../models/star_color.dart';

class StarCell extends StatelessWidget {
  const StarCell({
    super.key,
    required this.color,
    this.onTap,
  });

  final StarColor? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: 渲染单个星块
    return const Placeholder();
  }
}
