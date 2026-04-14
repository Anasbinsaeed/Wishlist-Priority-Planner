import 'package:flutter/material.dart';
import '../models/wish.dart';
import '../core/theme/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final WishPriority priority;
  final bool small;

  const PriorityBadge({super.key, required this.priority, this.small = false});

  Color get _color => switch (priority) {
    WishPriority.low => Colors.green,
    WishPriority.medium => Colors.orange,
    WishPriority.high => Colors.deepOrange,
    WishPriority.critical => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
