import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/owner/owner_bloc.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerBloc, OwnerState>(
      builder: (context, state) {
        if (state is OwnerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OwnerError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is OwnerLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Total Penjualan',
                      'Rp ${state.stats['today_sales']?.toStringAsFixed(0) ?? '0'}',
                      Icons.payments,
                      Colors.teal,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      context,
                      'Transaksi',
                      '${state.stats['today_transactions'] ?? '0'}',
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = state.recentTransactions[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.shopping_bag_outlined),
                        ),
                        title: Text(
                          tx['transaction_number'] ??
                              'TX-${tx['id'].toString().substring(0, 8)}',
                        ),
                        subtitle: Text(
                          tx['created_at'].toString().split('T')[0],
                        ),
                        trailing: Text(
                          'Rp ${tx['total_amount']?.toString() ?? '0'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Gunakan data untuk memulai.'));
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
