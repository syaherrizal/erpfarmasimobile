import 'package:flutter/material.dart';

class OwnerApprovalPage extends StatelessWidget {
  const OwnerApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.approval, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Persetujuan (Approval)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Daftar approval (purchase, opname) akan muncul di sini.'),
          ],
        ),
      ),
    );
  }
}
