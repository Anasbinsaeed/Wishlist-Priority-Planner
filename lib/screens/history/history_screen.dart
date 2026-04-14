import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wish.dart';
import '../../providers/wish_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/priority_badge.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishes = context.watch<WishProvider>().wishes;
    final completed =
        wishes.where((w) => w.status == WishStatus.completed).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final archived =
        wishes.where((w) => w.status == WishStatus.archived).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return GradientScaffold(
      appBar: AppBar(title: const Text('History')),
      body: completed.isEmpty && archived.isEmpty
          ? const EmptyState(
              icon: Icons.history_rounded,
              title: 'No history yet',
              subtitle: 'Completed and archived wishes will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (completed.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'Completed (${completed.length})',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  ...completed.map((w) => _HistoryCard(wish: w)),
                  const SizedBox(height: 16),
                ],
                if (archived.isNotEmpty) ...[
                  _SectionLabel(
                    label: 'Archived (${archived.length})',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  ...archived.map((w) => _HistoryCard(wish: w)),
                ],
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Wish wish;
  const _HistoryCard({required this.wish});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = wish.status == WishStatus.completed;

    return GestureDetector(
      onTap: () => context.push('/wish/${wish.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.cardGradientDark
              : AppColors.cardGradientLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: isDark ? AppShadows.dark : AppShadows.light,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    (isCompleted ? AppColors.success : AppColors.textSecondary)
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_outline
                    : Icons.archive_outlined,
                size: 18,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      PriorityBadge(priority: wish.priority, small: true),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(wish.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
