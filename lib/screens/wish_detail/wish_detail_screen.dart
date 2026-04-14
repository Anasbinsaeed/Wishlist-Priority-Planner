import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wish.dart';
import '../../providers/wish_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_scaffold.dart';

class WishDetailScreen extends StatefulWidget {
  final String wishId;
  const WishDetailScreen({super.key, required this.wishId});

  @override
  State<WishDetailScreen> createState() => _WishDetailScreenState();
}

class _WishDetailScreenState extends State<WishDetailScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _markDone(BuildContext context, Wish wish) async {
    await context.read<WishProvider>().updateStatus(
      wish.id,
      WishStatus.completed,
    );
    _confetti.play();
  }

  void _shareWish(Wish wish, String? categoryName) {
    final buffer = StringBuffer();
    buffer.writeln('🌟 ${wish.title}');
    if (wish.description != null && wish.description!.isNotEmpty) {
      buffer.writeln(wish.description);
    }
    buffer.writeln('Priority: ${wish.priority.name}');
    if (categoryName != null) buffer.writeln('Category: $categoryName');
    if (wish.deadline != null) {
      buffer.writeln(
        'Deadline: ${DateFormat('MMM d, yyyy  h:mm a').format(wish.deadline!)}',
      );
    }
    buffer.writeln('\nShared from Wishlist Planner');
    Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final wish = context.watch<WishProvider>().wishes.cast<Wish?>().firstWhere(
      (w) => w?.id == widget.wishId,
      orElse: () => null,
    );

    if (wish == null) {
      return GradientScaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Wish not found',
          subtitle: 'It may have been deleted.',
        ),
      );
    }

    final category = context.read<CategoryProvider>().findById(wish.categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue =
        wish.deadline != null &&
        wish.deadline!.isBefore(DateTime.now()) &&
        wish.status == WishStatus.active;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Wish Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareWish(wish, category?.name),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/wish/${wish.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, wish),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.cardGradientDark
                  : AppColors.cardGradientLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: isDark ? AppShadows.dark : AppShadows.light,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PriorityBadge(priority: wish.priority),
                    const SizedBox(width: 8),
                    StatusBadge(status: wish.status),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  wish.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (wish.description != null &&
                    wish.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    wish.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.cardGradientDark
                  : AppColors.cardGradientLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: isDark ? AppShadows.dark : AppShadows.light,
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.label_outline,
                  label: 'Category',
                  value: category?.name ?? wish.categoryId,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: DateFormat('MMM d, yyyy').format(wish.createdAt),
                ),
                if (wish.deadline != null)
                  _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Deadline',
                    value: DateFormat(
                      'MMM d, yyyy  •  h:mm a',
                    ).format(wish.deadline!),
                    valueColor: isOverdue ? AppColors.danger : null,
                  ),
                if (wish.notes != null && wish.notes!.isNotEmpty)
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: wish.notes!,
                  ),
              ],
            ),
          ),
          if (wish.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: wish.tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '#$t',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 28),
          Text(
            'Change Status',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...WishStatus.values
              .where((s) => s != wish.status)
              .map(
                (s) => _StatusButton(
                  status: s,
                  onPressed: () => s == WishStatus.completed
                      ? _markDone(context, wish)
                      : context.read<WishProvider>().updateStatus(wish.id, s),
                ),
              ),
          const SizedBox(height: 16),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.primary,
              AppColors.success,
              Color(0xFFF59E0B),
              Colors.white,
            ],
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Wish wish) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Wish',
      message: 'Delete "${wish.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (confirmed && context.mounted) {
      await context.read<WishProvider>().deleteWish(wish.id);
      if (context.mounted) context.go(AppRoutes.home);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final WishStatus status;
  final VoidCallback onPressed;

  const _StatusButton({required this.status, required this.onPressed});

  Color get _color => switch (status) {
    WishStatus.active => AppColors.primary,
    WishStatus.completed => AppColors.success,
    WishStatus.archived => AppColors.textSecondary,
  };

  IconData get _icon => switch (status) {
    WishStatus.active => Icons.play_circle_outline_rounded,
    WishStatus.completed => Icons.check_circle_outline_rounded,
    WishStatus.archived => Icons.archive_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon, size: 20, color: _color),
                const SizedBox(width: 10),
                Text(
                  'Mark as ${status.name}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
