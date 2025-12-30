import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import '../widgets/payment_dialog.dart';
import '../../data/models/hive/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class CartView extends StatelessWidget {
  final String organizationId;
  final String branchId;
  final String cashierId;
  final bool isTablet;

  const CartView({
    super.key,
    required this.organizationId,
    required this.branchId,
    required this.cashierId,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: isTablet
            ? Border(left: BorderSide(color: Theme.of(context).dividerColor))
            : null,
      ),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header
              _buildHeader(context, state),

              // Customer & Doctor Selection
              _buildSelectionArea(context),

              // Cart Items
              Expanded(
                child: state.items.isEmpty
                    ? _buildEmptyState(context)
                    : _buildItemList(context, state),
              ),

              // Summary & Checkout
              _buildSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Keranjang',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.totalItems}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Recall', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('+ Jasa', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          _buildSelectionRow(
            context,
            icon: Icons.person_outline,
            label: 'Pelanggan',
            value: 'Umum (General)',
            actionLabel: 'Ganti',
          ),
          const Divider(height: 16),
          _buildSelectionRow(
            context,
            icon: Icons.medical_information_outlined,
            label: 'Dokter (Opsional)',
            value: '-',
            actionLabel: 'Pilih',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String actionLabel,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cari produk di panel kiri atau tekan\nF2 untuk mulai transaksi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, CartState state) {
    return ListView.builder(
      itemCount: state.items.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp ${item.product.price.toStringAsFixed(0)} / ${item.product.unit ?? '-'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => context.read<CartCubit>().updateQuantity(
                      item.product.id,
                      -1,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => context.read<CartCubit>().updateQuantity(
                      item.product.id,
                      1,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, CartState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Promo Code Placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
                SizedBox(width: 8),
                Text(
                  'Pasang Kode Promo / Diskon',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Details
          _buildSummaryRow(
            context,
            'Subtotal',
            'Rp ${state.totalAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Pajak (11%)',
            'Rp 0',
          ), // Simplified for now
          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Rp ${state.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: AppTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.items.isEmpty
                  ? null
                  : () async {
                      final transaction = await showDialog<TransactionModel>(
                        context: context,
                        builder: (dialogContext) => PaymentDialog(
                          totalAmount: state.totalAmount,
                          items: state.items
                              .map(
                                (item) => TransactionItemModel(
                                  productId: item.product.id,
                                  productName: item.product.name,
                                  quantity: item.quantity,
                                  price: item.product.price,
                                  unitName: item.product.unit ?? '-',
                                ),
                              )
                              .toList(),
                          organizationId: organizationId,
                          branchId: branchId,
                          cashierId: cashierId,
                        ),
                      );

                      if (transaction != null && context.mounted) {
                        context.read<PosBloc>().add(
                          PosTransactionSaved(transaction),
                        );
                        context.read<CartCubit>().clearCart();
                        if (!isTablet) {
                          Navigator.pop(context); // Close BottomSheet on mobile
                        }
                      }
                    },
              icon: const Icon(Icons.payments_outlined),
              label: const Text(
                'Bayar (F3)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
