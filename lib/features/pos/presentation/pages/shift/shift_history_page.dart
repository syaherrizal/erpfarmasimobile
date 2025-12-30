import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:erpfarmasimobile/core/theme/app_theme.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/shift_history/shift_history_cubit.dart';
import 'package:erpfarmasimobile/features/pos/presentation/cubit/shift_history/shift_history_state.dart';
import 'package:erpfarmasimobile/features/app_mode/presentation/cubit/branch_context_cubit.dart';

class ShiftHistoryPage extends StatefulWidget {
  const ShiftHistoryPage({super.key});

  @override
  State<ShiftHistoryPage> createState() => _ShiftHistoryPageState();
}

class _ShiftHistoryPageState extends State<ShiftHistoryPage> {
  @override
  void initState() {
    super.initState();
    final branchState = context.read<BranchContextCubit>().state;
    if (branchState is BranchContextLoaded) {
      context.read<ShiftHistoryCubit>().fetchHistory(
        branchState.selectedBranchId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Shift'), centerTitle: true),
      body: BlocBuilder<ShiftHistoryCubit, ShiftHistoryState>(
        builder: (context, state) {
          if (state is ShiftHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShiftHistoryError) {
            return Center(
              child: Text(
                'Gagal memuat riwayat: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is ShiftHistoryLoaded) {
            if (state.shifts.isEmpty) {
              return const Center(child: Text('Belum ada riwayat shift.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.shifts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shift = state.shifts[index];
                final currencyFormat = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );
                final statusColor = shift.status == 'open'
                    ? Colors.green
                    : Colors.grey;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: statusColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy HH:mm',
                                  ).format(shift.openTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                shift.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kasir',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    shift.cashierName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total Akhir',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    currencyFormat.format(
                                      shift.actualEndCash ?? 0,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (shift.note != null && shift.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Catatan: ${shift.note}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
