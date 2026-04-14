import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wish.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/empty_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final categories = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: analytics.totalWishes == 0
          ? const EmptyState(
              icon: Icons.bar_chart_rounded,
              title: 'No data yet',
              subtitle: 'Add some wishes to see your analytics.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _OverviewRow(analytics: analytics),
                const SizedBox(height: 16),
                _AnalyticsCard(
                  title: 'Completion Rate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(analytics.completionRate * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            '${analytics.completedCount} of ${analytics.totalWishes} done',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: analytics.completionRate,
                          minHeight: 12,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _AnalyticsCard(
                  title: 'By Priority',
                  child: Column(
                    children: analytics.byPriority.entries.map((e) {
                      final ratio = analytics.totalWishes == 0
                          ? 0.0
                          : e.value / analytics.totalWishes;
                      return _BarRow(
                        label: e.key.name,
                        value: e.value,
                        ratio: ratio,
                        color: _priorityColor(e.key),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (analytics.byCategory.isNotEmpty)
                  _AnalyticsCard(
                    title: 'By Category',
                    child: Column(
                      children: analytics.byCategory.entries.map((e) {
                        final ratio = analytics.totalWishes == 0
                            ? 0.0
                            : e.value / analytics.totalWishes;
                        return _BarRow(
                          label: categories.findById(e.key)?.name ?? e.key,
                          value: e.value,
                          ratio: ratio,
                          color: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                if (analytics.upcomingDeadlines.isNotEmpty) ...[
                  SectionHeader(title: 'Due This Week'),
                  const SizedBox(height: 8),
                  ...analytics.upcomingDeadlines.map(
                    (w) => _DeadlineItem(wish: w),
                  ),
                ],
                if (analytics.overdueWishes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Overdue (${analytics.overdueWishes.length})',
                    titleColor: AppColors.danger,
                  ),
                  const SizedBox(height: 8),
                  ...analytics.overdueWishes.map(
                    (w) => _DeadlineItem(wish: w, isOverdue: true),
                  ),
                ],
              ],
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

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnalyticsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppShadows.dark : AppShadows.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final AnalyticsProvider analytics;
  const _OverviewRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Total',
          value: '${analytics.totalWishes}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        _StatTile(
          label: 'Active',
          value: '${analytics.activeCount}',
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(width: 10),
        _StatTile(
          label: 'Done',
          value: '${analytics.completedCount}',
          color: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: isDark ? AppShadows.dark : AppShadows.light,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;
  final double ratio;
  final Color color;

  const _BarRow({
    required this.label,
    required this.value,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineItem extends StatelessWidget {
  final Wish wish;
  final bool isOverdue;

  const _DeadlineItem({required this.wish, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppColors.danger : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.access_time_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              wish.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            DateFormat('MMM d, h:mm a').format(wish.deadline!),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
