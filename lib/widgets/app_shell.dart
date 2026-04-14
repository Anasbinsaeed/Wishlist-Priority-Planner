import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/wishlist_filter_provider.dart';
import '../providers/wish_provider.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  void _onTap(BuildContext context, int index) async {
    if (index != shell.currentIndex) {
      final filter = context.read<WishlistFilterProvider>();
      if (filter.sheetOpen) {
        filter.setSheetOpen(false);
        await Navigator.of(context, rootNavigator: true).maybePop();
      }
    }
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final showFab = shell.currentIndex == 0 || shell.currentIndex == 1;
    final sheetOpen = context.watch<WishlistFilterProvider>().sheetOpen;
    final activeCount = context.watch<WishProvider>().activeWishes.length;

    return Scaffold(
      body: shell,
      floatingActionButton: showFab && !sheetOpen
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.wishCreate),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _PillTabBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => _onTap(context, i),
        activeWishCount: activeCount,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _kItems = [
  _TabItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _TabItem(
    icon: Icons.list_alt_outlined,
    activeIcon: Icons.list_alt_rounded,
    label: 'Wishlist',
  ),
  _TabItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Analytics',
  ),
  _TabItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

class _PillTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int activeWishCount;

  const _PillTabBar({
    required this.currentIndex,
    required this.onTap,
    required this.activeWishCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 6, 12, bottomPadding > 0 ? 4 : 8),
            child: _SpringTabRow(
              currentIndex: currentIndex,
              isDark: isDark,
              activeWishCount: activeWishCount,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpringTabRow extends StatefulWidget {
  final int currentIndex;
  final bool isDark;
  final int activeWishCount;
  final ValueChanged<int> onTap;

  const _SpringTabRow({
    required this.currentIndex,
    required this.isDark,
    required this.activeWishCount,
    required this.onTap,
  });

  @override
  State<_SpringTabRow> createState() => _SpringTabRowState();
}

class _SpringTabRowState extends State<_SpringTabRow>
    with SingleTickerProviderStateMixin {
  static const n = 4;

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 40,
  );

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this);
    _ctrl.value = widget.currentIndex / (n - 1);
  }

  @override
  void didUpdateWidget(_SpringTabRow old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      final from = _ctrl.value;
      final to = widget.currentIndex / (n - 1);
      _ctrl.animateWith(SpringSimulation(_spring, from, to, _ctrl.velocity));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<double> _widths(double totalW, double springFrac) {
    final selectedF = springFrac * (n - 1);
    final unit = totalW / (n + 1);
    final widths = List.generate(n, (i) {
      final dist = (i - selectedF).abs();
      final extra = (1.0 - dist * dist).clamp(0.0, 1.0);
      return unit + unit * extra;
    });
    final sum = widths.fold(0.0, (a, b) => a + b);
    final scale = totalW / sum;
    return widths.map((w) => w * scale).toList();
  }

  List<double> _lefts(List<double> widths) {
    final lefts = <double>[];
    double x = 0;
    for (final w in widths) {
      lefts.add(x);
      x += w;
    }
    return lefts;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final frac = _ctrl.value.clamp(0.0, 1.0);
            final selectedF = frac * (n - 1);
            final widths = _widths(totalW, frac);
            final lefts = _lefts(widths);

            return Stack(
              children: List.generate(n, (i) {
                final dist = (i - selectedF).abs();
                final selectedness = (1.0 - dist * dist).clamp(0.0, 1.0);
                final badge = i == 1 && widget.activeWishCount > 0
                    ? widget.activeWishCount
                    : null;

                return Positioned(
                  left: lefts[i],
                  top: 0,
                  bottom: 0,
                  width: widths[i],
                  child: _TabCell(
                    item: _kItems[i],
                    selectedness: selectedness,
                    isSelected: selectedness > 0.5,
                    isDark: widget.isDark,
                    badge: badge,
                    onTap: () => widget.onTap(i),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}

class _TabCell extends StatelessWidget {
  final _TabItem item;
  final double selectedness;
  final bool isSelected;
  final bool isDark;
  final int? badge;
  final VoidCallback onTap;

  const _TabCell({
    required this.item,
    required this.selectedness,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final s = selectedness;
    final iconColor = Color.lerp(
      isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
      AppColors.primary,
      s,
    )!;
    final iconSize = 22.0 + 4.0 * s;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: s * 0.12),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              badge != null
                  ? Badge(
                      label: Text(
                        '$badge',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: AppColors.danger,
                      child: Icon(
                        s > 0.5 ? item.activeIcon : item.icon,
                        size: iconSize,
                        color: iconColor,
                      ),
                    )
                  : Icon(
                      s > 0.5 ? item.activeIcon : item.icon,
                      size: iconSize,
                      color: iconColor,
                    ),
              if (s > 0.05) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Opacity(
                    opacity: (s * s * s).clamp(0.0, 1.0),
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
