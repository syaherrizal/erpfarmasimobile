import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PosRootPage extends StatelessWidget {
  const PosRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Mode'),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: const Center(child: Text('POS Dashboard Placeholder')),
    );
  }
}
