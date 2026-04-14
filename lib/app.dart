import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/wish_provider.dart';
import 'providers/category_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wishlist_filter_provider.dart';
import 'providers/wish_form_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/wish_selection_provider.dart';

class WishlistApp extends StatelessWidget {
  const WishlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => WishProvider()),
        ChangeNotifierProxyProvider<WishProvider, AnalyticsProvider>(
          create: (_) => AnalyticsProvider(),
          update: (_, wishProvider, analytics) {
            analytics!.update(wishProvider.wishes);
            return analytics;
          },
        ),
        ChangeNotifierProvider(create: (_) => WishlistFilterProvider()),
        ChangeNotifierProvider(create: (_) => WishFormProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => WishSelectionProvider()),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsProvider, ThemeMode>(
      (s) => s.themeMode,
    );

    return MaterialApp.router(
      title: 'Wishlist Planner',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
