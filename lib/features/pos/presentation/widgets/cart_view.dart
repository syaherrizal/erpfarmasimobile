import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import '../widgets/payment_dialog.dart';
import '../../data/models/hive/transaction_model.dart';

class CartView extends StatelessWidget {
  final String organizationId;
  final String branchId;
  final String cashierId;

  const CartView({
    super.key,
    required this.organizationId,
    required this.branchId,
    required this.cashierId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const Center(child: Text('Keranjang kosong'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                      'Rp ${item.product.price.toStringAsFixed(0)} x ${item.quantity}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => context
                              .read<CartCubit>()
                              .updateQuantity(item.product.id, -1),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => context
                              .read<CartCubit>()
                              .updateQuantity(item.product.id, 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp ${state.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
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
                          Navigator.pop(context); // Close BottomSheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Transaksi Berhasil Disimpan (Offline)',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Bayar Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
