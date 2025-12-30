import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erpfarmasimobile/core/di/injection.dart';
import 'package:erpfarmasimobile/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/cart/cart_cubit.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/pos_home_screen.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/pos_profile_page.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/branch_context_cubit.dart';

import 'package:erpfarmasimobile/features/pos/presentation/cubit/sync/product_sync_cubit.dart';

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

        final branchState = context.read<BranchContextCubit>().state;
        if (branchState is BranchContextLoaded) {
          orgId = branchState.organizationId;
          branchId = branchState.selectedBranchId;
        }

        if (authState is AuthAuthenticated) {
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
                  sl<PosBloc>()..add(const PosInitialDataRequested()),
            ),
            BlocProvider(create: (context) => sl<CartCubit>()),
            BlocProvider(
              create: (context) =>
                  sl<ProductSyncCubit>()..sync(orgId, branchId),
            ),
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
