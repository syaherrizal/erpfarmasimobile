import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:erpfarmasimobile/features/auth/presentation/pages/login_page.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/owner_root_page.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/pos_root_page.dart';
import 'package:erpfarmasimobile/features/auth/presentation/pages/initial_context_page.dart';
import 'package:erpfarmasimobile/features/manager/presentation/pages/manager_root_page.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/pages/mode_selection_page.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/pages/branch_selection_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/pos', builder: (context, state) => const PosRootPage()),
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerRootPage(),
      ),
      GoRoute(
        path: '/owner',
        builder: (context, state) => const OwnerRootPage(),
      ),
      GoRoute(
        path: '/select-mode',
        builder: (context, state) => const ModeSelectionPage(),
      ),
      GoRoute(
        path: '/init-context',
        builder: (context, state) => const InitialContextPage(),
      ),
      GoRoute(
        path: '/select-branch',
        builder: (context, state) => const BranchSelectionPage(),
      ),
    ],
  );
}
