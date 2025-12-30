import 'package:flutter/material.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../bloc/owner/owner_bloc.dart';
import 'owner_dashboard_screen.dart';

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
        if (authState is AuthAuthenticated) {
          orgId = authState.profile?['organization_id'] ?? 'PLACEHOLDER';
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
              children: const [
                OwnerDashboardScreen(),
                Center(child: Text('Riwayat Transaksi (Coming Soon)')),
                Center(child: Text('Setelan Owner (Coming Soon)')),
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
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
