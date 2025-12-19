import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final int views;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.views,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metaStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 12,
    );

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
        height: 140,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Text("No Image"),
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),

                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(timeAgo(date), style: metaStyle),

                      const Spacer(),

                      Icon(Icons.visibility, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text("$views", style: metaStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedNewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final int views;
  final VoidCallback? onTap;

  const FeaturedNewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.views,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
  child: ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "FEATURED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo(date),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),

                    const Spacer(),

                    const Icon(Icons.visibility, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      "$views",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
