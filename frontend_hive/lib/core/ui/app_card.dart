import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: .8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
    return onTap == null
        ? card
        : Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: card));
  }
}
