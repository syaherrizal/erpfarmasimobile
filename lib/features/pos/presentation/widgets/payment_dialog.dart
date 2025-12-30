import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/hive/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final List<TransactionItemModel> items;
  final String organizationId;
  final String branchId;
  final String cashierId;
  final String shiftId;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.items,
    required this.organizationId,
    required this.branchId,
    required this.cashierId,
    required this.shiftId,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _amountPaidController = TextEditingController();
  double _change = 0;
  String _paymentMethod = 'Tunai';

  @override
  void initState() {
    super.initState();
    _amountPaidController.addListener(_calculateChange);
  }

  void _calculateChange() {
    final paid = double.tryParse(_amountPaidController.text) ?? 0;
    setState(() {
      _change = paid - widget.totalAmount;
    });
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    if (_paymentMethod != 'Tunai' || _change >= 0) {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        createdAtEpoch: DateTime.now().millisecondsSinceEpoch,
        totalAmount: widget.totalAmount,
        items: widget.items,
        organizationId: widget.organizationId,
        branchId: widget.branchId,
        cashierId: widget.cashierId,
        paymentMethod: _paymentMethod,
        shiftId: widget.shiftId,
      );
      Navigator.pop(context, transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Bill Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Tagihan',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${widget.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Tunai', 'QRIS', 'Transfer'].map((method) {
                final isSelected = _paymentMethod == method;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _paymentMethod = method),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          method,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Cash Input
            if (_paymentMethod == 'Tunai') ...[
              const Text(
                'Jumlah Bayar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountPaidController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan jumlah tunai...',
                  prefixText: 'Rp ',
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                onSubmitted: (_) => _confirmSelection(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kembalian',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rp ${_change < 0 ? 0 : _change.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _change < 0
                          ? AppTheme.errorColor
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (_paymentMethod != 'Tunai' || _change >= 0)
                        ? _confirmSelection
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesaikan Transaksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
