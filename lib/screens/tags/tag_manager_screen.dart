import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/wish_provider.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_confirm_dialog.dart';

class TagManagerScreen extends StatelessWidget {
  const TagManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishes = context.watch<WishProvider>().wishes;
    final tagCounts = <String, int>{};
    for (final w in wishes) {
      for (final t in w.tags) {
        tagCounts[t] = (tagCounts[t] ?? 0) + 1;
      }
    }
    final tags = tagCounts.keys.toList()..sort();

    return GradientScaffold(
      appBar: AppBar(title: const Text('Tag Manager')),
      body: tags.isEmpty
          ? const EmptyState(
              icon: Icons.tag_rounded,
              title: 'No tags yet',
              subtitle: 'Add tags to your wishes to organize them.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: tags.length,
              itemBuilder: (context, i) {
                final tag = tags[i];
                final count = tagCounts[tag]!;
                return _TagTile(
                  tag: tag,
                  count: count,
                  onDelete: () => _confirmDeleteTag(context, tag),
                );
              },
            ),
    );
  }

  void _confirmDeleteTag(BuildContext context, String tag) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Remove Tag',
      message: 'Remove "#$tag" from all wishes?',
      confirmLabel: 'Remove',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<WishProvider>().removeTagFromAllWishes(tag);
  }
}

class _TagTile extends StatelessWidget {
  final String tag;
  final int count;
  final VoidCallback onDelete;

  const _TagTile({
    required this.tag,
    required this.count,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          '$count wish${count == 1 ? '' : 'es'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.danger,
            size: 20,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
