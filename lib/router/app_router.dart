import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../data/app_store.dart';
import '../data/session_store.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_overview_screen.dart';
import '../screens/dashboard/dashboard_shell.dart';
import '../screens/dashboard/login_screen.dart';
import '../screens/dashboard/orders_screen.dart';
import '../screens/dashboard/products_screen.dart';
import '../screens/dashboard/settings_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/shop/shop_shell.dart';
import '../screens/shop/storefront_screen.dart';
import '../theme/tokens.dart';
import '../widgets/ui/feedback.dart';

part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refresh = GoRouterRefreshStream(
    AppConfig.useDemo
        ? DemoMemoryStore.instance.authCtrl.stream
        : SessionStore.instance.changes,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: kIsWeb ? '/shop/whimsical' : '/dashboard',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final loggingIn = path == '/dashboard/login';
      final dashboard = path.startsWith('/dashboard');
      if (!dashboard) return null;
      final signedIn = isSignedInNow;
      if (!signedIn && !loggingIn) return '/dashboard/login';
      if (signedIn && loggingIn) return '/dashboard';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.blush,
      body: WhimsicalError(
        message: state.error?.toString() ?? 'That page wandered off.',
      ),
    ),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => kIsWeb ? '/shop/whimsical' : '/dashboard',
      ),
      GoRoute(
        path: '/dashboard/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardOverviewScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductsScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          final slug = state.pathParameters['slug'] ?? 'whimsical';
          return ShopShell(slug: slug, child: child);
        },
        routes: [
          GoRoute(
            path: '/shop/:slug',
            pageBuilder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return NoTransitionPage(child: StorefrontScreen(slug: slug));
            },
            routes: [
              GoRoute(
                path: 'product/:id',
                pageBuilder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  final id = state.pathParameters['id']!;
                  return NoTransitionPage(
                    child: ProductDetailScreen(slug: slug, id: id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
