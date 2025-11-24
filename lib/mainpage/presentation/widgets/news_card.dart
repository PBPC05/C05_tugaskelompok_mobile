import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String title;
  const NewsCard({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(title, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
