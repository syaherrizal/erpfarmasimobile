import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';

class PosProfilePage extends StatelessWidget {
  const PosProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Kasir';
        String email = '';
        String role = 'Cashier';

        if (state is AuthAuthenticated) {
          name =
              state.profile?['full_name'] ??
              state.user.email?.split('@')[0] ??
              'Kasir';
          email = state.user.email ?? '';
          role =
              state.profile?['role']?['name']?.toString().toUpperCase() ??
              'CASHIER';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF0F766E),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(email, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: Colors.teal.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Pengaturan Aplikasi'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Bantuan & Dukungan'),
                onTap: () {},
              ),
              const Divider(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar (Logout)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade100),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
