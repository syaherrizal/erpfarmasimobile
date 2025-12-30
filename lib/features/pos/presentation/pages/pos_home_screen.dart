import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos/pos_bloc.dart';
import '../cubit/cart/cart_cubit.dart';
import '../cubit/sync/product_sync_cubit.dart';
import '../bloc/shift/shift_bloc.dart';
import '../widgets/product_list_row.dart';
import '../widgets/cart_view.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../features/auth/presentation/bloc/organization/organization_context_cubit.dart';
import '../../../../features/auth/presentation/bloc/organization/organization_context_state.dart';
import '../../../../features/app_mode/presentation/cubit/branch_context_cubit.dart';

class PosHomeScreen extends StatefulWidget {
  final String organizationId;
  final String branchId;
  final String cashierId;

  const PosHomeScreen({
    super.key,
    required this.organizationId,
    required this.branchId,
    required this.cashierId,
  });

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleHardwareKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _searchFocusNode.requestFocus();
      } else if (event.logicalKey == LogicalKeyboardKey.f3) {
        // Pay logic handled in CartView via F3 shortcut if needed
        // but can be triggered here if we expose the method
      } else if (event.logicalKey == LogicalKeyboardKey.f4) {
        context.read<CartCubit>().clearCart();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _searchController.clear();
        context.read<PosBloc>().add(const PosSearchRequested(''));
      }
    }
  }

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider.value(value: context.read<PosBloc>()),
            BlocProvider.value(value: context.read<ShiftBloc>()),
          ],
          child: CartView(
            organizationId: widget.organizationId,
            branchId: widget.branchId,
            cashierId: widget.cashierId,
            isTablet: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleHardwareKey,
      child: BlocListener<ProductSyncCubit, ProductSyncState>(
        listener: (context, state) {
          if (state is ProductSyncSuccess) {
            context.read<PosBloc>().add(const PosInitialDataRequested());
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ResponsiveLayout(
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletLayout(context),
          ),
          floatingActionButton: ResponsiveLayout.isMobile(context)
              ? _buildMobileFab(context)
              : null,
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildSearchBar(context),
        Expanded(child: _buildProductList(context)),
        _buildFooterShortcuts(),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side: Catalog
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildTableHeader(),
              Expanded(child: _buildProductList(context)),
              _buildFooterShortcuts(),
            ],
          ),
        ),
        // Right Side: Cart
        Expanded(
          flex: 3,
          child: CartView(
            organizationId: widget.organizationId,
            branchId: widget.branchId,
            cashierId: widget.cashierId,
            isTablet: true,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FarmaDigi POS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                BlocBuilder<OrganizationContextCubit, OrganizationContextState>(
                  builder: (context, orgState) {
                    return BlocBuilder<BranchContextCubit, BranchContextState>(
                      builder: (context, branchState) {
                        String orgName = '';
                        String branchName = '';

                        if (orgState is OrganizationContextLoaded) {
                          orgName = orgState.organizationName;
                        }
                        if (branchState is BranchContextLoaded) {
                          branchName = branchState.selectedBranchName;
                        }

                        return Text(
                          '$orgName - $branchName',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF0F766E),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<ProductSyncCubit, ProductSyncState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state is ProductSyncLoading ? Icons.sync : Icons.refresh,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: state is ProductSyncLoading
                    ? null
                    : () => context.read<ProductSyncCubit>().sync(
                        widget.organizationId,
                        widget.branchId,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Cari Produk (F2)...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: const Icon(Icons.qr_code_scanner, size: 20),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          context.read<PosBloc>().add(PosSearchRequested(value));
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 2),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Nama Produk / SKU',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Kategori / Golongan',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Harga',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        if (state is PosLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PosLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text('Produk tidak ditemukan'));
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductListRow(
                product: product,
                onAdd: () => context.read<CartCubit>().addToCart(product),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFooterShortcuts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Wrap(
        spacing: 16,
        children: [
          _buildShortcutHint('F2', 'Cari'),
          _buildShortcutHint('F3', 'Bayar'),
          _buildShortcutHint('F4', 'Kosongkan'),
          _buildShortcutHint('ESC', 'Batal'),
        ],
      ),
    );
  }

  Widget _buildShortcutHint(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            key,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFab(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showMobileCart(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: Text(
            '${state.totalItems} Item | Rp ${state.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
