import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:provider/provider.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  final Function(bool updated)? editResult;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    required this.editResult,
  });

  String _formatDate(DateTime date) {
    // Simple date formatter without intl package
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final displayCatMap = {
      "all": "All Categories",
      "f1": "Formula 1/FIA",
      "championship": "Championship",
      "team": "Team",
      "driver": "Driver",
      "constructor": "Constructor",
      "race": "Race",
      "analysis": "Analysis",
      "history": "F1 History",
      "fanbase": "F1 Fanbase",
      "exclusive": "Exclusive",
      "other": "Other",
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    news.thumbnail,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),

                // Category & Featured
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 3.0,
                      ),
                      child: Text(
                        displayCatMap[news.category]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    if (news.isFeatured)
                      Container(
                        decoration: const BoxDecoration(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 2.0,
                        ),
                        child: const Text(
                          '★ Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Author, creation date, views, comments
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Written by ${news.username} | ${_formatDate(news.createdAt)}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          "${news.newsViews}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 4.0),
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 2.0),
                        Text(
                          "${news.newsComments}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),

                // Content preview
                Text(
                  news.content.length > 100
                      ? '${news.content.substring(0, 100)}...'
                      : news.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),

                // Edit and delete buttons
                Row(
                  children: [
                    TextButton(
                      child: const Text("Edit"),
                      onPressed: () async {
                        final updated = await context.push(
                          '/news/edit-news/',
                          extra: news,
                        );

                        if (editResult != null) {
                          editResult!(updated == true);
                        }
                      },
                    ),
                    TextButton(
                      child: const Text("Delete"),
                      onPressed: () async {
                        // Confirm user wants to delete
                        final request = context.read<CookieRequest>();

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete Article"),
                              content: Text(
                                "Are you sure you want to delete '${news.title}'?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );

                        // If user cancels
                        if (confirm != true) return;

                        // If user continues
                        final response = await request.postJson(
                          "http://localhost:8000/news/${news.id}/delete-flutter/",
                          jsonEncode({})
                        );

                        if (!context.mounted) return;

                        if (response["status"] == "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Article successfully deleted!"))
                          );

                          if (editResult != null) {
                            editResult!(true);
                          }
                        } else {
                          debugPrint("Error deleting article: ${response['message']}");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
