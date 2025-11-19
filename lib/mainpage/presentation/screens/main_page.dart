import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/admins'),
              child: const Text("Go to Admins"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/authentication'),
              child: const Text("Go to Authentication"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/forums'),
              child: const Text("Go to Forums"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/history'),
              child: const Text("Go to History"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/information'),
              child: const Text("Go to Information"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/news'),
              child: const Text("Go to News"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/prediction'),
              child: const Text("Go to Prediction"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/user'),
              child: const Text("Go to User"),
            ),
          ],
        ),
      ),
    );
  }
}
