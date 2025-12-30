import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_state.dart';
import 'package:erpfarmasimobile/core/di/injection.dart';
import 'package:erpfarmasimobile/features/owner/presentation/bloc/owner/owner_bloc.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/owner_dashboard_screen.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/owner_reports_page.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/owner_approval_page.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/owner_settings_page.dart';

class OwnerRootPage extends StatefulWidget {
  const OwnerRootPage({super.key});

  @override
  State<OwnerRootPage> createState() => _OwnerRootPageState();
}

class _OwnerRootPageState extends State<OwnerRootPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String orgId = 'PLACEHOLDER';
        final orgState = context.read<OrganizationContextCubit>().state;
        if (orgState is OrganizationContextLoaded) {
          orgId = orgState.organizationId;
        }

        return BlocProvider(
          create: (context) =>
              sl<OwnerBloc>()..add(OwnerDashboardDataRequested(orgId)),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _selectedIndex == 0 ? 'Owner Dashboard' : 'Owner Mode',
              ),
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    context.go('/login');
                  },
                ),
              ],
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                const OwnerDashboardScreen(),
                const OwnerReportsPage(),
                const OwnerApprovalPage(),
                const OwnerSettingsPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: const Color(0xFF0F766E),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Laporan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.approval_outlined),
                  activeIcon: Icon(Icons.approval),
                  label: 'Approval',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Setelan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
