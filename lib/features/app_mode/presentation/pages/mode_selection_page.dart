import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/app_mode/app_mode.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/app_mode_cubit.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF14B8A6)),
              );
            }

            final role = state.profile?['role']?['name'] ?? 'cashier';
            final name = state.profile?['full_name'] ?? 'User';

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang,',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF0F766E),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pilih mode aplikasi untuk memulai operasional Anda hari ini.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                      child: ListView(children: _buildModeCards(context, role)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildModeCards(BuildContext context, String role) {
    final List<Widget> cards = [];

    // Always show POS
    cards.add(
      _ModeCard(
        title: 'Mode Kasir (POS)',
        description:
            'Transaksi penjualan, manajemen antrian, dan laporan kasir harian.',
        icon: Icons.shopping_cart_checkout_rounded,
        color: const Color(0xFF14B8A6),
        onTap: () {
          context.read<AppModeCubit>().setMode(AppMode.pos);
          context.go('/pos');
        },
      ),
    );

    // Show Manager if owner or manager
    if (role == 'owner' || role == 'manager') {
      cards.add(const SizedBox(height: 16));
      cards.add(
        _ModeCard(
          title: 'Mode Manager Cabang',
          description:
              'Approval stok, stock opname, dan manajemen operasional cabang.',
          icon: Icons.manage_accounts_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () {
            context.read<AppModeCubit>().setMode(AppMode.manager);
            context.go('/manager');
          },
        ),
      );
    }

    // Show Owner if owner
    if (role == 'owner') {
      cards.add(const SizedBox(height: 16));
      cards.add(
        _ModeCard(
          title: 'Mode Owner (Enterprise)',
          description:
              'Analisis performa seluruh cabang, laporan laba rugi, dan statistik bisnis.',
          icon: Icons.dashboard_customize_rounded,
          color: const Color(0xFF6366F1),
          onTap: () {
            context.read<AppModeCubit>().setMode(AppMode.owner);
            context.go('/owner');
          },
        ),
      );
    }

    return cards;
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
