import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/owner/presentation/pages/owner_root_page.dart';
import '../../features/pos/presentation/pages/pos_root_page.dart';
import '../../features/manager/presentation/pages/manager_root_page.dart';
import '../../features/app_mode/presentation/pages/mode_selection_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login', // Start at login for now
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/pos', builder: (context, state) => const PosRootPage()),
      GoRoute(
        path: '/owner',
        builder: (context, state) => const OwnerRootPage(),
      ),
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerRootPage(),
      ),
      GoRoute(
        path: '/select-mode',
        builder: (context, state) => const ModeSelectionPage(),
      ),
    ],
    // Redirect logic will be added here later to check Auth State
  );
}
