import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';

class ForumsRepliesCard extends StatelessWidget {
  final ForumReply reply;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const ForumsRepliesCard({
    Key? key,
    required this.reply,
    required this.onLike,
    required this.onDelete,
  }) : super(key: key);

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and username
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[700],
                radius: 20,
                child: Text(
                  reply.username![0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.username!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(reply.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Content
          Text(
            reply.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12.0),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Like Button
              InkWell(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      reply.userHasLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: reply.userHasLiked ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${reply.likes}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),

              // Delete Button (if owner)
              if (reply.isOwner || reply.isForumOwner)
                InkWell(
                  onTap: onDelete,
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[400], size: 18),
                      const SizedBox(width: 4.0),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}