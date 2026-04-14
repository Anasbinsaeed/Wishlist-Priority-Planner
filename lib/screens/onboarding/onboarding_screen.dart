import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/notifications/notification_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();

  static const _infoPagesCount = 2;
  static const _totalPages = 3;

  static const _pages = [
    _PageData(
      icon: Icons.format_list_bulleted_rounded,
      gradient: [Color(0xFF2CBF6E), Color(0xFF1A8A4E)],
      title: 'Prioritize Your Wishes',
      description:
          'Organize your desires by priority levels and never lose track of what matters most to you.',
    ),
    _PageData(
      icon: Icons.bar_chart_rounded,
      gradient: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      title: 'Track Your Progress',
      description:
          'Visualize achievements with beautiful analytics and get personalized recommendations.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OnboardingProvider>().setPage(0);
      _pageController.jumpToPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final ob = context.read<OnboardingProvider>();
    if (ob.currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _requestNotifications() async {
    await NotificationService.instance.requestPermission();
    if (!mounted) return;
    await context.read<SettingsProvider>().setNotificationsEnabled(true);
    await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = context.watch<OnboardingProvider>().currentPage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNotifPage = currentPage == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: context.read<OnboardingProvider>().setPage,
                    itemCount: _totalPages,
                    itemBuilder: (_, i) {
                      if (i < _infoPagesCount) {
                        return _OnboardingPage(data: _pages[i]);
                      }
                      return const _NotificationsPage();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(_totalPages, (i) {
                          final active = currentPage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 6),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      FilledButton(
                        onPressed: isNotifPage ? _requestNotifications : _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isNotifPage ? 'Allow' : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isNotifPage
                                  ? Icons.notifications_active_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (isNotifPage)
              Positioned(
                top: 8,
                right: 16,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.45),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String description;

  const _PageData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: data.gradient.first.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(data.icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Stay on Track',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Get timely reminders when your wish deadlines are approaching so you never miss a goal.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FeaturePill(
                icon: Icons.alarm_rounded,
                label: 'Deadline alerts',
                isDark: isDark,
              ),
              _FeaturePill(
                icon: Icons.emoji_events_rounded,
                label: 'Milestone reminders',
                isDark: isDark,
              ),
              _FeaturePill(
                icon: Icons.do_not_disturb_off_rounded,
                label: 'No spam, ever',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
