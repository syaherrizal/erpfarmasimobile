import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/app_mode/app_mode.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/app_mode_cubit.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/branch_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_state.dart';

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

            final profile = state.profile;
            final roleName = (profile?['role']?['name'] as String? ?? 'Kasir')
                .trim()
                .toLowerCase();
            final name = profile?['full_name'] ?? 'User';

            // Enterprise check: Is the user the technical owner of the organization?
            final isOrgOwner =
                profile?['organization']?['owner_id'] == state.user.id;

            // Final role status
            final isOwner = roleName == 'owner' || isOrgOwner;
            final role = isOwner ? 'owner' : roleName;

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
                      child: BlocBuilder<PermissionCubit, PermissionState>(
                        builder: (context, permState) {
                          final permissions = permState is PermissionLoaded
                              ? permState.permissions
                              : <String>{};
                          return ListView(
                            children: _buildModeCards(
                              context,
                              role,
                              permissions,
                            ),
                          );
                        },
                      ),
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

  void _onModeSelected(BuildContext context, AppMode mode) {
    context.read<AppModeCubit>().setMode(mode);

    if (mode == AppMode.owner) {
      context.go('/owner');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      final orgId = authState.profile?['organization_id'];

      if (orgId != null) {
        context.read<BranchContextCubit>().loadMemberships(userId, orgId);
        // Permissions already loaded by InitialContextPage
        context.go('/select-branch');
      }
    }
  }

  List<Widget> _buildModeCards(
    BuildContext context,
    String role,
    Set<String> permissions,
  ) {
    final List<Widget> cards = [];
    final bool isOwner = role == 'owner';

    // 1. Mode Kasir (POS)
    // Criteria: Is Owner OR has menu.pos OR any pos permission
    final bool hasPosAccess =
        isOwner ||
        permissions.contains('menu.pos') ||
        permissions.any((p) => p.startsWith('pos.'));

    if (hasPosAccess) {
      cards.add(
        _ModeCard(
          title: 'Mode Kasir (POS)',
          description:
              'Transaksi penjualan, manajemen antrian, dan laporan kasir harian.',
          icon: Icons.shopping_cart_checkout_rounded,
          color: const Color(0xFF14B8A6),
          onTap: () => _onModeSelected(context, AppMode.pos),
        ),
      );
    }

    // 2. Mode Manager Cabang
    // Criteria: Is Owner OR has any manager-level menu
    final bool hasManagerAccess =
        isOwner ||
        permissions.any(
          (p) =>
              p == 'menu.inventory' ||
              p == 'menu.reporting' ||
              p == 'menu.purchasing' ||
              p == 'menu.finance' ||
              p == 'menu.marketing' ||
              p == 'menu.products' ||
              p == 'menu.settings',
        );

    if (hasManagerAccess) {
      if (cards.isNotEmpty) cards.add(const SizedBox(height: 16));
      cards.add(
        _ModeCard(
          title: 'Mode Manager Cabang',
          description:
              'Approval stok, stock opname, dan manajemen operasional cabang.',
          icon: Icons.manage_accounts_rounded,
          color: const Color(0xFFF59E0B),
          onTap: () => _onModeSelected(context, AppMode.manager),
        ),
      );
    }

    // 3. Mode Owner (Enterprise)
    // Criteria: Is Owner OR has menu.dashboard
    final bool hasOwnerAccess =
        isOwner || permissions.contains('menu.dashboard');

    if (hasOwnerAccess) {
      if (cards.isNotEmpty) cards.add(const SizedBox(height: 16));
      cards.add(
        _ModeCard(
          title: 'Mode Owner (Enterprise)',
          description:
              'Analisis performa seluruh cabang, laporan laba rugi, dan statistik bisnis.',
          icon: Icons.dashboard_customize_rounded,
          color: const Color(0xFF6366F1),
          onTap: () => _onModeSelected(context, AppMode.owner),
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
