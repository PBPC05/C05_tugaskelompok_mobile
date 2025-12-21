class Forum {
  final String id;
  final String? userId;
  final String? username;
  final String title;
  final String content;
  final int views;
  final int likes;
  final int repliesCount;
  final bool isHot;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool userHasLiked;

  Forum({
    required this.id,
    this.userId,
    this.username,
    required this.title,
    required this.content,
    required this.views,
    required this.likes,
    required this.repliesCount,
    required this.isHot,
    required this.createdAt,
    required this.updatedAt,
    this.userHasLiked = false,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id']?.toString() ?? json['forums_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? 
               json['user']?['id']?.toString() ?? 
               json['author_id']?.toString(),
      username: json['user']?['username'] ?? 
                json['author'] ?? 
                json['username'] ?? 
                'Anonymous',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      views: json['forums_views'] ?? json['views'] ?? 0,
      likes: json['forums_likes'] ?? json['likes'] ?? 0,
      repliesCount: json['forums_replies_counts'] ?? json['replies_count'] ?? 0,
      isHot: json['is_hot'] ?? false,
      createdAt: DateTime.parse(json['created_at'] is String 
          ? json['created_at'] 
          : json['created_at']?.toIso8601String() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] is String 
          ? json['updated_at'] 
          : json['updated_at']?.toIso8601String() ?? DateTime.now().toIso8601String()),
      userHasLiked: json['user_has_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'id': id,
      'user_id': userId,
      'username': username,
    };
  }
}

class ForumListResponse {
  final int count;
  final int numPages;
  final int page;
  final List<Forum> results;

  ForumListResponse({
    required this.count,
    required this.numPages,
    required this.page,
    required this.results,
  });

  factory ForumListResponse.fromJson(Map<String, dynamic> json) {
    return ForumListResponse(
      count: json['count'] ?? 0,
      numPages: json['num_pages'] ?? 1,
      page: json['page'] ?? 1,
      results: (json['results'] as List)
          .map((item) => Forum.fromJson(item))
          .toList(),
    );
  }
}