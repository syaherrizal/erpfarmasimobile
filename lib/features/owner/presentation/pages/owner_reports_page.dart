import 'package:flutter/material.dart';

class OwnerReportsPage extends StatelessWidget {
  const OwnerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Laporan Owner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Fitur laporan lengkap akan segera hadir.'),
          ],
        ),
      ),
    );
  }
}
