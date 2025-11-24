import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("2025 Standings")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text("Back to MainPage"),
        ),
      ),
    );
  }
}
