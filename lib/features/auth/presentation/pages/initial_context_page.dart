import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/organization/organization_context_state.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_state.dart';

class InitialContextPage extends StatefulWidget {
  const InitialContextPage({super.key});

  @override
  State<InitialContextPage> createState() => _InitialContextPageState();
}

class _InitialContextPageState extends State<InitialContextPage> {
  @override
  void initState() {
    super.initState();
    _startSequencing();
  }

  void _startSequencing() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrganizationContextCubit>().loadOrganizationContext(
        authState.user.id,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrganizationContextCubit, OrganizationContextState>(
          listener: (context, state) {
            if (state is OrganizationContextLoaded) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                // Next sequence: Load Permissions
                context.read<PermissionCubit>().loadPermissions(
                  authState.user.id,
                  state.organizationId,
                );
              }
            } else if (state is OrganizationContextError) {
              _showErrorDialog(state.message);
            }
          },
        ),
        BlocListener<PermissionCubit, PermissionState>(
          listener: (context, state) {
            if (state is PermissionLoaded) {
              // Context is ready, proceed to mode selection
              context.go('/select-mode');
            } else if (state is PermissionError) {
              _showErrorDialog(state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Color(0xFF2DD4BF),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Menyiapkan Sesi Anda',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Memvalidasi organisasi & perijinan...',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Gagal Inisialisasi',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            },
            child: Text(
              'Kembali ke Login',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2DD4BF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
