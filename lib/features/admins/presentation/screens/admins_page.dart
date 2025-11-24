import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminsPage extends StatelessWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admins")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text("Back to MainPage"),
        ),
      ),
    );
  }
}
