import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';

class ForumsRepliesCard extends StatelessWidget {
  final ForumReply reply;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final bool isAdmin;
  final bool isLoggedIn;

  const ForumsRepliesCard({
    Key? key,
    required this.reply,
    required this.onLike,
    required this.onDelete,
    this.isAdmin = false,
    this.isLoggedIn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDelete = isAdmin || reply.isOwner || reply.isForumOwner;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with username and time
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  radius: 16,
                  child: Text(
                    reply.username[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(reply.createdAt),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badges for owner/forum owner
                if (reply.isOwner)
                  _buildBadge('Owner', Colors.blue[800]!),
                if (reply.isForumOwner && !reply.isOwner)
                  _buildBadge('OP', Colors.green[800]!),
              ],
            ),
            const SizedBox(height: 12),
            
            // Content
            Text(
              reply.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button
                InkWell(
                  onTap: isLoggedIn ? onLike : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to like replies'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        reply.userHasLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: reply.userHasLiked ? Colors.red[400] : Colors.grey[400],
                        size: 18,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${reply.likes}',
                        style: TextStyle(
                          color: reply.userHasLiked ? Colors.red[400] : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Delete button (only show if user has permission)
                if (canDelete)
                  InkWell(
                    onTap: isLoggedIn ? onDelete : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to delete replies'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
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
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}