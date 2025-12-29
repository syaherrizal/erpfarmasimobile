import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerRootPage extends StatelessWidget {
  const OwnerRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Mode'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: const Center(child: Text('Owner Dashboard Placeholder')),
    );
  }
}
