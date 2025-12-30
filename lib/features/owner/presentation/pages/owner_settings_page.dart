import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/pos_profile_page.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/organization/owner_organization_settings_page.dart';
import 'package:erpfarmasimobile/features/owner/presentation/pages/branch/owner_branch_list_page.dart';

class OwnerSettingsPage extends StatelessWidget {
  const OwnerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Setelan Owner',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Umum'),
          _buildSettingsItem(
            context,
            icon: Icons.business,
            title: 'Organisasi',
            subtitle: 'Atur info perusahaan & legalitas',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OwnerOrganizationSettingsPage(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.store,
            title: 'Branch / Cabang',
            subtitle: 'Manajemen daftar cabang',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OwnerBranchListPage(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.people_outline,
            title: 'Karyawan',
            subtitle: 'Kelola akses staff & penggajian',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Karyawan Coming Soon')),
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Akun'),
          _buildSettingsItem(
            context,
            icon: Icons.swap_horizontal_circle,
            title: 'Ganti Mode Aplikasi',
            subtitle: 'Beralih ke Kasir (POS) / Manager',
            onTap: () {
              context.go('/select-mode');
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile Saya',
            subtitle: 'Edit info pribadi & keamanan',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PosProfilePage()),
              );
            },
          ),

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Keluar (Logout)',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
