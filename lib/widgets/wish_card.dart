import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wish.dart';
import '../core/theme/app_theme.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class WishCard extends StatelessWidget {
  final Wish wish;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkDone;
  final VoidCallback? onLongPress;

  const WishCard({
    super.key,
    required this.wish,
    required this.onTap,
    this.onDelete,
    this.onMarkDone,
    this.onLongPress,
  });

  bool get _isOverdue =>
      wish.deadline != null &&
      wish.deadline!.isBefore(DateTime.now()) &&
      wish.status == WishStatus.active;

  bool get _isActive => wish.status == WishStatus.active;

  String _deadlineCountdown() {
    if (wish.deadline == null) return '';
    final now = DateTime.now();
    final diff = wish.deadline!.difference(now);
    if (diff.isNegative) {
      final days = diff.inDays.abs();
      if (days == 0) return 'Overdue today';
      return '$days day${days == 1 ? '' : 's'} overdue';
    }
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    if (diff.inDays < 7) return 'Due in ${diff.inDays} days';
    return DateFormat('MMM d, yyyy').format(wish.deadline!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOverdue
              ? AppColors.danger.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: isDark ? AppShadows.dark : AppShadows.light,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 44,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: _priorityColor(wish.priority),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wish.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  decoration:
                                      wish.status == WishStatus.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: wish.status == WishStatus.completed
                                      ? Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.45)
                                      : null,
                                ),
                          ),
                          if (wish.description != null &&
                              wish.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              wish.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_isActive && onMarkDone != null) ...[
                      const SizedBox(width: 8),
                      _MarkDoneButton(onTap: onMarkDone!),
                    ] else if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    PriorityBadge(priority: wish.priority, small: true),
                    const SizedBox(width: 6),
                    StatusBadge(status: wish.status, small: true),
                    const Spacer(),
                    if (wish.deadline != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isOverdue
                              ? AppColors.danger.withValues(alpha: 0.1)
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.access_time_rounded,
                              size: 12,
                              color: _isOverdue
                                  ? AppColors.danger
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                            ),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _deadlineCountdown(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _isOverdue
                                        ? AppColors.danger
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.55),
                                  ),
                                ),
                                Text(
                                  DateFormat('h:mm a').format(wish.deadline!),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _isOverdue
                                        ? AppColors.danger.withValues(
                                            alpha: 0.8,
                                          )
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.38),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (wish.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: wish.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(WishPriority p) => switch (p) {
    WishPriority.low => const Color(0xFF22C55E),
    WishPriority.medium => const Color(0xFFF59E0B),
    WishPriority.high => const Color(0xFFF97316),
    WishPriority.critical => AppColors.danger,
  };
}

class _MarkDoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MarkDoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 13, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Mark as done',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
