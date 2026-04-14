import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/wish.dart';
import '../../providers/wish_provider.dart';
import '../../providers/wishlist_filter_provider.dart';
import '../../providers/wish_selection_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../widgets/wish_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/top_snackbar.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<WishlistFilterProvider>();
    final selection = context.watch<WishSelectionProvider>();
    final wishProvider = context.watch<WishProvider>();
    final wishes = filter.applyAll(wishProvider.wishes);
    final hasFilter =
        filter.statusFilter != null ||
        filter.priorityFilter != null ||
        filter.searchQuery.isNotEmpty;
    final isSelecting = selection.isSelecting;
    final allSelected =
        wishes.isNotEmpty && wishes.every((w) => selection.isSelected(w.id));

    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<WishSelectionProvider>().exitSelection();
      },
      child: GradientScaffold(
        appBar: AppBar(
          title: isSelecting
              ? Text('${selection.count} selected')
              : const Text('All Wishes'),
          leading: isSelecting
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      context.read<WishSelectionProvider>().exitSelection(),
                )
              : null,
          actions: isSelecting
              ? [
                  TextButton(
                    onPressed: () {
                      if (allSelected) {
                        context.read<WishSelectionProvider>().deselectAll();
                      } else {
                        context.read<WishSelectionProvider>().selectAll(
                          wishes.map((w) => w.id).toList(),
                        );
                      }
                    },
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    tooltip: 'Delete selected',
                    onPressed: selection.count == 0
                        ? null
                        : () => _confirmDeleteSelected(
                            context,
                            selection,
                            wishProvider,
                          ),
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.sort_rounded),
                    tooltip: 'Sort',
                    onPressed: () => _showSortSheet(context),
                  ),
                  if (hasFilter)
                    IconButton(
                      icon: const Icon(Icons.filter_list_off),
                      tooltip: 'Clear filters',
                      onPressed: filter.clearFilters,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterSheet(context),
                    ),
                ],
          bottom: isSelecting
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _SearchBar(
                      query: filter.searchQuery,
                      onChanged: filter.setSearchQuery,
                    ),
                  ),
                ),
        ),
        body: wishes.isEmpty
            ? EmptyState(
                icon: Icons.list_alt_outlined,
                title: hasFilter ? 'No matches found' : 'No wishes yet',
                subtitle: hasFilter
                    ? 'Try adjusting your search or filters.'
                    : 'Tap + to add your first wish.',
                actionLabel: hasFilter ? 'Clear' : 'Add Wish',
                onAction: hasFilter
                    ? filter.clearFilters
                    : () => context.push(AppRoutes.wishCreate),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: SectionHeader(
                      title:
                          '${wishes.length} wish${wishes.length == 1 ? '' : 'es'}',
                      actionLabel: hasFilter ? 'Clear filters' : null,
                      onAction: hasFilter ? filter.clearFilters : null,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: wishes.length,
                      itemBuilder: (context, i) {
                        final wish = wishes[i];
                        final isSelected = selection.isSelected(wish.id);

                        if (isSelecting) {
                          return _SelectableWishCard(
                            wish: wish,
                            isSelected: isSelected,
                            onTap: () => context
                                .read<WishSelectionProvider>()
                                .toggle(wish.id),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Dismissible(
                              key: ValueKey(wish.id),
                              background: SwipeBackground(
                                color: AppColors.success,
                                icon: Icons.check_rounded,
                                alignment: Alignment.centerLeft,
                              ),
                              secondaryBackground: SwipeBackground(
                                color: AppColors.danger,
                                icon: Icons.delete_outline,
                                alignment: Alignment.centerRight,
                              ),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  if (wish.status == WishStatus.active) {
                                    await context
                                        .read<WishProvider>()
                                        .updateStatus(
                                          wish.id,
                                          WishStatus.completed,
                                        );
                                  }
                                  return false;
                                }
                                return await AppConfirmDialog.show(
                                  context,
                                  title: 'Delete Wish',
                                  message: 'Delete "${wish.title}"?',
                                  confirmLabel: 'Delete',
                                  isDanger: true,
                                );
                              },
                              onDismissed: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  final deleted = wish;
                                  bool undone = false;

                                  final provider = context.read<WishProvider>();

                                  provider.softDeleteWish(deleted.id);

                                  TopSnackbar.show(
                                    context,
                                    message: '"${deleted.title}" deleted',
                                    actionLabel: 'Undo',
                                    onAction: () {
                                      undone = true;
                                      provider.restoreWish(deleted);
                                    },
                                    duration: const Duration(seconds: 3),
                                  );

                                  Future.delayed(
                                    const Duration(seconds: 3),
                                    () {
                                      if (!undone)
                                        provider.commitDelete(deleted.id);
                                    },
                                  );
                                }
                              },
                              child: WishCard(
                                wish: wish,
                                onTap: () => context.push('/wish/${wish.id}'),
                                onMarkDone: wish.status == WishStatus.active
                                    ? () => context
                                          .read<WishProvider>()
                                          .updateStatus(
                                            wish.id,
                                            WishStatus.completed,
                                          )
                                    : null,
                                onLongPress: () => context
                                    .read<WishSelectionProvider>()
                                    .enterSelection(wish.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmDeleteSelected(
    BuildContext context,
    WishSelectionProvider selection,
    WishProvider wishProvider,
  ) async {
    final count = selection.count;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete $count wish${count == 1 ? '' : 'es'}',
      message:
          'Delete $count selected wish${count == 1 ? '' : 'es'}? This cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;
    final ids = selection.selected.toList();
    context.read<WishSelectionProvider>().exitSelection();
    await wishProvider.deleteWishes(ids);
  }

  void _showFilterSheet(BuildContext context) {
    final filterProvider = context.read<WishlistFilterProvider>();
    filterProvider.setSheetOpen(true);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => const _FilterSheet(),
    ).whenComplete(() => filterProvider.setSheetOpen(false));
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => const _SortSheet(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: query)
        ..selection = TextSelection.collapsed(offset: query.length),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search wishes...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => onChanged(''),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
      ),
    );
  }
}

class SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;
  const SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<WishlistFilterProvider>();
    final options = [
      (WishSortOrder.dateDesc, 'Newest first', Icons.arrow_downward_rounded),
      (WishSortOrder.dateAsc, 'Oldest first', Icons.arrow_upward_rounded),
      (
        WishSortOrder.priorityHigh,
        'Priority: High → Low',
        Icons.priority_high_rounded,
      ),
      (
        WishSortOrder.priorityLow,
        'Priority: Low → High',
        Icons.low_priority_rounded,
      ),
      (
        WishSortOrder.deadlineAsc,
        'Deadline: Soonest first',
        Icons.schedule_rounded,
      ),
      (WishSortOrder.titleAz, 'Title: A → Z', Icons.sort_by_alpha_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Sort by', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...options.map(
            (o) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                o.$3,
                color: filter.sortOrder == o.$1
                    ? AppColors.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              title: Text(o.$2),
              trailing: filter.sortOrder == o.$1
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                filter.setSortOrder(o.$1);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableWishCard extends StatelessWidget {
  final Wish wish;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectableWishCard({
    required this.wish,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.cardGradientDark
              : AppColors.cardGradientLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark ? AppShadows.dark : AppShadows.light,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration: wish.status == WishStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (wish.description != null &&
                        wish.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        wish.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<WishlistFilterProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter by Status',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: filter.statusFilter == null,
                onTap: () => filter.setStatusFilter(null),
              ),
              ...WishStatus.values.map(
                (s) => _FilterChip(
                  label: s.name,
                  selected: filter.statusFilter == s,
                  onTap: () => filter.setStatusFilter(s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Filter by Priority',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: filter.priorityFilter == null,
                onTap: () => filter.setPriorityFilter(null),
              ),
              ...WishPriority.values.map(
                (p) => _FilterChip(
                  label: p.name,
                  selected: filter.priorityFilter == p,
                  onTap: () => filter.setPriorityFilter(p),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
