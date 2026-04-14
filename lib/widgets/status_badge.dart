import 'package:flutter/material.dart';
import '../models/wish.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final WishStatus status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  Color get _color => switch (status) {
    WishStatus.active => AppColors.primary,
    WishStatus.completed => Colors.blue,
    WishStatus.archived => AppColors.textSecondary,
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
        status.name.toUpperCase(),
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
