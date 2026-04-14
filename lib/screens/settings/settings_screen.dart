import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wish_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/gradient_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _rateApp(BuildContext context) async {
    const packageId = 'com.planity.wishlistpriorityplanner.uoh';
    final inAppReview = InAppReview.instance;

    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        await Future.delayed(const Duration(seconds: 2));

        await inAppReview.openStoreListing(appStoreId: packageId);
      } else {
        await inAppReview.openStoreListing(appStoreId: packageId);
      }
    } catch (e) {
      await inAppReview.openStoreListing(appStoreId: packageId);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opening Play Store...')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _SettingsSection(
            title: 'Appearance',
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Row(
                      children: [
                        _ThemeOption(
                          icon: Icons.brightness_auto_rounded,
                          label: 'System',
                          selected: settings.themeMode == ThemeMode.system,
                          onTap: () => settings.setThemeMode(ThemeMode.system),
                        ),
                        const SizedBox(width: 10),
                        _ThemeOption(
                          icon: Icons.light_mode_rounded,
                          label: 'Light',
                          selected: settings.themeMode == ThemeMode.light,
                          onTap: () => settings.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 10),
                        _ThemeOption(
                          icon: Icons.dark_mode_rounded,
                          label: 'Dark',
                          selected: settings.themeMode == ThemeMode.dark,
                          onTap: () => settings.setThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SettingsSection(
            title: 'Preferences',
            isDark: isDark,
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Deadline reminders'),
                value: settings.notificationsEnabled,
                onChanged: (enabled) =>
                    _handleNotificationToggle(context, settings, enabled),
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.label_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                title: const Text('Categories'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => context.push(AppRoutes.categories),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                title: const Text('History'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => context.push(AppRoutes.history),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tag_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                title: const Text('Tag Manager'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => context.push(AppRoutes.tags),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SettingsSection(
            title: 'About',
            isDark: isDark,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_outline,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
                title: const Text('Rate the App'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () => _rateApp(context),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 18,
                  ),
                ),
                title: const Text('Version'),
                trailing: Text(
                  AppConstants.appVersion,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _SettingsSection(
            title: 'Danger Zone',
            isDark: isDark,
            titleColor: AppColors.danger,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: AppColors.danger,
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Clear All Data',
                  style: TextStyle(color: AppColors.danger),
                ),
                onTap: () => _confirmReset(context, settings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleNotificationToggle(
    BuildContext context,
    SettingsProvider settings,
    bool enabled,
  ) async {
    if (!enabled) {
      await settings.setNotificationsEnabled(false);
      await NotificationService.instance.cancelAll();
      return;
    }

    final alreadyGranted = await NotificationService.instance
        .isPermissionGranted();

    if (alreadyGranted) {
      await settings.setNotificationsEnabled(true);
      return;
    }

    final granted = await NotificationService.instance
        .requestAndCheckPermission();

    if (granted) {
      await settings.setNotificationsEnabled(true);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permission denied. Enable notifications in system settings.',
            ),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
      await settings.setNotificationsEnabled(false);
    }
  }

  void _confirmReset(BuildContext context, SettingsProvider settings) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Clear All Data',
      message: 'This will reset all settings and data. Are you sure?',
      confirmLabel: 'Reset',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;

    await settings.resetAll();
    if (!context.mounted) return;

    await context.read<WishProvider>().loadWishes();
    await context.read<CategoryProvider>().loadCategories();

    context.read<OnboardingProvider>().setPage(0);

    context.go(AppRoutes.onboarding);
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;
  final Color? titleColor;

  const _SettingsSection({
    required this.title,
    required this.children,
    required this.isDark,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color:
                  titleColor ??
                  Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            boxShadow: selected ? AppShadows.primaryGlow : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected
                    ? Colors.white
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
