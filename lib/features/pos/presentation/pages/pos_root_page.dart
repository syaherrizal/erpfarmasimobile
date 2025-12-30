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
import 'package:erpfarmasimobile/features/pos/presentation/bloc/shift/shift_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/shift/shift_management_page.dart';

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
            BlocProvider(
              create: (context) =>
                  sl<ShiftBloc>()..add(CheckShiftStatus(branchId)),
            ),
          ],
          child: BlocConsumer<ShiftBloc, ShiftState>(
            listener: (context, shiftState) {
              // Optional: Redirect logic if needed
            },
            builder: (context, shiftState) {
              final bool isShiftOpen = shiftState is ShiftOpened;

              final List<Widget> screens = [
                isShiftOpen
                    ? PosHomeScreen(
                        organizationId: orgId,
                        branchId: branchId,
                        cashierId: cashierId,
                      )
                    : _buildShiftRequiredView(context),
                const ShiftManagementPage(),
                const Center(child: Text('Riwayat Transaksi (Coming Soon)')),
                const PosProfilePage(),
              ];

              return Scaffold(
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
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShiftRequiredView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.door_front_door_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const Text(
            'Shift Belum Dibuka',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda harus membuka shift terlebih dahulu\nuntuk melakukan transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Switch to Shift Tab
              });
            },
            child: const Text('Buka Menu Shift'),
          ),
        ],
      ),
    );
  }
}
