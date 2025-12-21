import 'package:flutter/material.dart';

class ForumsCard extends StatelessWidget {
  final String title;
  final String author;
  final String content;
  final String date;
  final int replies;
  final VoidCallback onTap;

  const ForumsCard({
    required this.title,
    required this.author,
    required this.content,
    required this.date,
    required this.replies,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mutedText = Colors.white.withOpacity(0.65);

    String timeAgo(String rawDate) {
      final dateTime = DateTime.parse(rawDate);
      final diff = DateTime.now().difference(dateTime);

      if (diff.inSeconds < 60) {
        return "just now";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes} minutes ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours} hours ago";
      } else if (diff.inDays < 7) {
        return "${diff.inDays} days ago";
      } else if (diff.inDays < 30) {
        return "${(diff.inDays / 7).floor()} weeks ago";
      } else if (diff.inDays < 365) {
        return "${(diff.inDays / 30).floor()} months ago";
      } else {
        return "${(diff.inDays / 365).floor()} years ago";
      }
    }


    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    author.isNotEmpty ? author : "Anonymous",
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedText,
                    ),
                  ),

                  const Spacer(),

                  const Icon(Icons.forum_outlined, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    "$replies replies",
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                "Read discussion →",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
