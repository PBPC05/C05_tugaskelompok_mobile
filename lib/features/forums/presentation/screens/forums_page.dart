import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForumsPage extends StatelessWidget {
  const ForumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forums")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text("Back to MainPage"),
        ),
      ),
    );
  }
}
