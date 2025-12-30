import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/hive/transaction_model.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final List<TransactionItemModel> items;

  const PaymentDialog({
    super.key,
    required this.totalAmount,
    required this.items,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Tagihan: Rp ${widget.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Metode Pembayaran:'),
            DropdownButton<String>(
              value: _paymentMethod,
              isExpanded: true,
              items: ['Tunai', 'QRIS', 'Transfer'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _paymentMethod = val!);
              },
            ),
            const SizedBox(height: 16),
            if (_paymentMethod == 'Tunai') ...[
              const Text('Jumlah Bayar:'),
              TextField(
                controller: _amountPaidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kembalian: Rp ${_change < 0 ? 0 : _change.toStringAsFixed(0)}',
                style: TextStyle(
                  color: _change < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: (_paymentMethod != 'Tunai' || _change >= 0)
              ? () {
                  final transaction = TransactionModel(
                    id: const Uuid().v4(),
                    createdAtEpoch: DateTime.now().millisecondsSinceEpoch,
                    totalAmount: widget.totalAmount,
                    items: widget.items,
                  );
                  Navigator.pop(context, transaction);
                }
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: const Text('Konfirmasi & Simpan'),
        ),
      ],
    );
  }
}
