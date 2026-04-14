import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/wishlist/wishlist_screen.dart';
import '../../screens/wish_detail/wish_detail_screen.dart';
import '../../screens/wish_form/wish_form_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/tags/tag_manager_screen.dart';
import '../../widgets/app_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const wishlist = '/wishlist';
  static const wishCreate = '/wishes/new';
  static const wishDetail = '/wish/:id';
  static const wishEdit = '/wish/:id/edit';
  static const analytics = '/analytics';
  static const settings = '/settings';
  static const categories = '/categories';
  static const history = '/history';
  static const tags = '/tags';
}

GoRouter createRouter(BuildContext context) {
  final settingsProvider = Provider.of<SettingsProvider>(
    context,
    listen: false,
  );

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: settingsProvider,
    redirect: (ctx, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splash) return null;
      final onboardingDone = settingsProvider.onboardingDone;
      if (!onboardingDone && loc != AppRoutes.onboarding)
        return AppRoutes.onboarding;
      if (onboardingDone && loc == AppRoutes.onboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, s) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, s) => _slideTransitionPage(const OnboardingScreen()),
      ),

      StatefulShellRoute.indexedStack(
        pageBuilder: (_, __, shell) =>
            _slideTransitionPage(AppShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, s) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wishlist,
                builder: (_, s) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                builder: (_, s) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (_, s) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.wishCreate,
        builder: (_, s) => const WishFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishDetail,
        builder: (_, s) => WishDetailScreen(wishId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.wishEdit,
        builder: (_, s) => WishFormScreen(wishId: s.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (_, s) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, s) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.tags,
        builder: (_, s) => const TagManagerScreen(),
      ),
    ],
  );
}

CustomTransitionPage<void> _slideTransitionPage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
