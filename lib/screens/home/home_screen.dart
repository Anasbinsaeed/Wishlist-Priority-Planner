import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wish.dart';
import '../../providers/wish_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/wish_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/gradient_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: const _HomeTab(),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final wishes = context.watch<WishProvider>();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<WishProvider>().loadWishes(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2CBF6E),
                  Color(0xFF1A8A4E),
                  Color(0xFF0F5C34),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HeroStat(
                      label: 'Total',
                      value: '${analytics.totalWishes}',
                    ),
                    _Divider(),
                    _HeroStat(
                      label: 'Active',
                      value: '${analytics.activeCount}',
                    ),
                    _Divider(),
                    _HeroStat(
                      label: 'Done',
                      value: '${analytics.completedCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: analytics.completionRate,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(analytics.completionRate * 100).toStringAsFixed(0)}% complete',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (analytics.weeklyCompletedCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.success,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'You completed ${analytics.weeklyCompletedCount} wish${analytics.weeklyCompletedCount == 1 ? '' : 'es'} this week!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (analytics.overdueWishes.isNotEmpty) ...[
            SectionHeader(
              title: 'Overdue (${analytics.overdueWishes.length})',
              titleColor: AppColors.danger,
            ),
            const SizedBox(height: 8),
            ...analytics.overdueWishes.map(
              (w) => WishCard(
                wish: w,
                onTap: () => context.push('/wish/${w.id}'),
                onMarkDone: () => context.read<WishProvider>().updateStatus(
                  w.id,
                  WishStatus.completed,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionHeader(
            title: 'Recent Wishes',
            actionLabel: 'See All',
            onAction: () => context.go(AppRoutes.wishlist),
          ),
          const SizedBox(height: 8),
          if (wishes.activeWishes.isEmpty)
            EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No recent wishes',
              subtitle: 'Start by adding your first wish.',
              actionLabel: 'Add Wish',
              onAction: () => context.push(AppRoutes.wishCreate),
            )
          else
            ...analytics.prioritySortedActive
                .take(5)
                .map(
                  (w) => WishCard(
                    wish: w,
                    onTap: () => context.push('/wish/${w.id}'),
                    onMarkDone: () => context.read<WishProvider>().updateStatus(
                      w.id,
                      WishStatus.completed,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}
