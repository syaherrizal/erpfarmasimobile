import 'package:flutter/material.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/pos_profile_page.dart';

class ManagerRootPage extends StatefulWidget {
  const ManagerRootPage({super.key});

  @override
  State<ManagerRootPage> createState() => _ManagerRootPageState();
}

class _ManagerRootPageState extends State<ManagerRootPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const InventoryScreen(),
    const StockOpnameScreen(),
    const ApprovalScreen(),
    const Center(child: Text('Riwayat Transaksi Cabang (Coming Soon)')),
    const PosProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Opname'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check),
            label: 'Approval',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Cabang'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Daftar Inventori akan muncul di sini')),
    );
  }
}

class StockOpnameScreen extends StatelessWidget {
  const StockOpnameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Form Stock Opname')),
    );
  }
}

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Manager'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Daftar Approval Stok & Transaksi')),
    );
  }
}
