import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_view.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key});

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  final _searchController = TextEditingController();

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.8,
        child: BlocProvider.value(
          value: context.read<CartCubit>(),
          child: const CartView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir FarmaDigi'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<PosBloc, PosState>(
            builder: (context, state) {
              if (state is PosLoaded) {
                return IconButton(
                  icon: Icon(
                    state.syncStatus == 'syncing'
                        ? Icons.sync
                        : Icons.sync_rounded,
                    color: state.syncStatus == 'error' ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<PosBloc>().add(
                      const PosRefreshProductsRequested(
                        'PLACEHOLDER',
                        'PLACEHOLDER',
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk atau scan barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {}, // Scan Logic
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement local search
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: BlocBuilder<PosBloc, PosState>(
              builder: (context, state) {
                if (state is PosLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PosError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is PosLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada produk tersedia. Silakan sinkronisasi.',
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onAdd: () {
                          context.read<CartCubit>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ditambahkan'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => _showCart(context),
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              '${state.totalItems} Item | Rp ${state.totalAmount.toStringAsFixed(0)}',
            ),
            backgroundColor: const Color(0xFF0F766E),
          );
        },
      ),
    );
  }
}
