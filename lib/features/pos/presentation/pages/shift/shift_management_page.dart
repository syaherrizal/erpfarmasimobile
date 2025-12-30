import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/branch_context_cubit.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/bloc/shift/shift_bloc.dart';
import 'package:erpfarmasimobile/features/pos/presentation/widgets/shift/close_shift_dialog.dart';
import 'package:erpfarmasimobile/features/pos/presentation/widgets/shift/open_shift_dialog.dart';
import 'package:erpfarmasimobile/features/pos/presentation/pages/shift/shift_history_page.dart';
import 'package:erpfarmasimobile/core/di/injection.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/shift_history/shift_history_cubit.dart';

class ShiftManagementPage extends StatelessWidget {
  const ShiftManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Shift'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => sl<ShiftHistoryCubit>(),
                    child: const ShiftHistoryPage(),
                  ),
                ),
              );
            },
            tooltip: 'Riwayat Shift',
          ),
        ],
      ),
      body: BlocConsumer<ShiftBloc, ShiftState>(
        listener: (context, state) {
          if (state is ShiftError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ShiftLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShiftOpened) {
            return _buildActiveShiftView(context, state);
          } else {
            return _buildClosedShiftView(context);
          }
        },
      ),
    );
  }

  Widget _buildClosedShiftView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            width: 400,
            child: Column(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kasir Sedang Tutup',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Buka shift baru untuk memulai transaksi penjualan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final result = await showDialog<double>(
                        context: context,
                        builder: (context) => const OpenShiftDialog(),
                      );

                      if (result != null && context.mounted) {
                        final authState = context.read<AuthBloc>().state;
                        final branchState = context
                            .read<BranchContextCubit>()
                            .state;

                        if (authState is AuthAuthenticated &&
                            branchState is BranchContextLoaded) {
                          context.read<ShiftBloc>().add(
                            OpenShift(
                              branchId: branchState.selectedBranchId,
                              cashierId: authState.user.id,
                              cashierName:
                                  authState.user.userMetadata?['full_name'] ??
                                  authState.user.email ??
                                  'Cashier',
                              startCash: result,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Buka Shift Baru'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveShiftView(BuildContext context, ShiftOpened state) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final shift = state.shift;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  radius: 24,
                  child: Icon(
                    Icons.timer_outlined,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Detail Shift Aktif',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RUNNING',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dimulai ${DateFormat('dd MMMM yyyy HH:mm').format(shift.openTime)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'KASIR',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shift.cashierName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cards Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Modal Awal',
                  currencyFormat.format(shift.startCash),
                  Icons.money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Saldo Sistem (Saat Ini)',
                  currencyFormat.format(shift.expectedEndCash),
                  Icons.account_balance_wallet,
                  isPrimary: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Section using LayoutBuilder for Responsiveness
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: isSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Operasional Kas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Input kas masuk/keluar atau tutup shift sekarang.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {}, // TODO: Implement Income
                                  icon: const Icon(
                                    Icons.arrow_downward,
                                    size: 16,
                                  ),
                                  label: const Text('Masuk'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {}, // TODO: Implement Expense
                                  icon: const Icon(
                                    Icons.arrow_upward,
                                    size: 16,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  label: const Text('Keluar'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (context) => CloseShiftDialog(
                                        expectedCash: shift.expectedEndCash,
                                      ),
                                    );

                                if (result != null && context.mounted) {
                                  context.read<ShiftBloc>().add(
                                    CloseShift(
                                      shiftId: shift.id,
                                      actualEndCash: result['actualCash'],
                                      note: result['note'],
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Tutup Shift'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Operasional Kas',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Input kas masuk/keluar atau tutup shift sekarang.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {}, // TODO: Implement Income
                                icon: const Icon(
                                  Icons.arrow_downward,
                                  size: 16,
                                ),
                                label: const Text('Kas Masuk'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {}, // TODO: Implement Expense
                                icon: const Icon(Icons.arrow_upward, size: 16),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                label: const Text('Kas Keluar'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) => CloseShiftDialog(
                                          expectedCash: shift.expectedEndCash,
                                        ),
                                      );

                                  if (result != null && context.mounted) {
                                    context.read<ShiftBloc>().add(
                                      CloseShift(
                                        shiftId: shift.id,
                                        actualEndCash: result['actualCash'],
                                        note: result['note'],
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.logout, size: 16),
                                label: const Text('Tutup Shift'),
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF0F766E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isPrimary ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Icon(
                icon,
                color: isPrimary ? Colors.white70 : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
