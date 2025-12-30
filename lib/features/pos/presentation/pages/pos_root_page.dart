import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import 'pos_home_screen.dart';
import 'pos_profile_page.dart';

class PosRootPage extends StatefulWidget {
  const PosRootPage({super.key});

  @override
  State<PosRootPage> createState() => _PosRootPageState();
}

class _PosRootPageState extends State<PosRootPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PosHomeScreen(),
    const Center(child: Text('Shift Management (Coming Soon)')),
    const Center(child: Text('Riwayat Transaksi (Coming Soon)')),
    const PosProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<PosBloc>()
            ..add(const PosInitialDataRequested('PLACEHOLDER', 'PLACEHOLDER')),
        ),
        BlocProvider(create: (context) => sl<CartCubit>()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
