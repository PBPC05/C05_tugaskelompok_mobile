import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/history/drivers'),
              child: const Text("Driver History (User)"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/history/drivers/admin'),
              child: const Text("Driver History (Admin)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text("Back to MainPage"),
            ),
          ],
        ),
      ),
    );
  }
}
