import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/news/data/comment_model.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final Function(bool updated)? editResult;

  const CommentCard({super.key, required this.comment, required this.editResult});

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: const BorderSide(color: Colors.black)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading line
              Text(
                comment.username,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 4,),

              // Time
              Text(
                _formatDate(comment.createdAt),
                style: const TextStyle(fontSize: 14.0,  color: Colors.black),
              ),
              const SizedBox(height: 12,),

              // Content
              Text(
                comment.content,
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),

              // Delete button
              TextButton(
                      child: const Text("Delete"),
                      onPressed: () async {
                        // Confirm user wants to delete
                        final request = context.read<CookieRequest>();

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete Comment"),
                              content: const Text(
                                "Are you sure you want to delete this comment?",
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
                          "http://localhost:8000/news/comment/${comment.id}/delete-flutter/",
                          jsonEncode({})
                        );

                        if (!context.mounted) return;

                        if (response["status"] == "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Comment successfully deleted!"))
                          );

                          if (editResult != null) {
                            editResult!(true);
                          }
                        } else {
                          debugPrint("Error deleting comment: ${response['message']}");
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
