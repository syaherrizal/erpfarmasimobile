import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import 'pos_home_screen.dart';
import 'pos_profile_page.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';

class PosRootPage extends StatefulWidget {
  const PosRootPage({super.key});

  @override
  State<PosRootPage> createState() => _PosRootPageState();
}

class _PosRootPageState extends State<PosRootPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String orgId = 'PLACEHOLDER';
        String branchId = 'PLACEHOLDER';
        String cashierId = 'PLACEHOLDER';

        if (authState is AuthAuthenticated) {
          orgId = authState.profile?['organization_id'] ?? 'PLACEHOLDER';
          branchId = authState.profile?['assigned_branch_id'] ?? 'PLACEHOLDER';
          cashierId = authState.user.id;
        }

        final List<Widget> screens = [
          PosHomeScreen(
            organizationId: orgId,
            branchId: branchId,
            cashierId: cashierId,
          ),
          const Center(child: Text('Shift Management (Coming Soon)')),
          const Center(child: Text('Riwayat Transaksi (Coming Soon)')),
          const PosProfilePage(),
        ];

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  sl<PosBloc>()..add(PosInitialDataRequested(orgId, branchId)),
            ),
            BlocProvider(create: (context) => sl<CartCubit>()),
          ],
          child: Scaffold(
            body: IndexedStack(index: _selectedIndex, children: screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0F766E),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'POS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: 'Shift',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
