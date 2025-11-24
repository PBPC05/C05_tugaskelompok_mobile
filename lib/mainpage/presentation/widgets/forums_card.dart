import 'package:flutter/material.dart';

class ForumsCard extends StatelessWidget {
  final String title;
  final String author;

  const ForumsCard({
    required this.title,
    required this.author,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A1A1A),
      child: ListTile(
        title: Text(title),
        subtitle: Text("by $author"),
      ),
    );
  }
}
