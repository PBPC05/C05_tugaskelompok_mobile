import 'dart:convert';

class ForumReply {
  int id;
  String username;
  String content;
  int likes;
  DateTime createdAt;
  bool userHasLiked;
  bool isOwner;
  bool isForumOwner;

  ForumReply({
    required this.id,
    required this.username,
    required this.content,
    required this.likes,
    required this.createdAt,
    required this.userHasLiked,
    required this.isOwner,
    required this.isForumOwner,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    // Parse tanggal dari berbagai format
    DateTime parseDateTime(dynamic date) {
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          try {
            // Coba format lain
            return DateTime.parse(date.replaceAll('T', ' ').substring(0, 19));
          } catch (e2) {
            return DateTime.now();
          }
        }
      }
      return DateTime.now();
    }

    return ForumReply(
      id: json["id"] ?? 0,
      username: json["username"] ?? 'Anonymous',
      content: json["content"] ?? json["replies_content"] ?? '',
      likes: json["likes"] ?? 0,
      createdAt: parseDateTime(json["created_at"]),
      userHasLiked: json["user_has_liked"] ?? false,
      isOwner: json["is_owner"] ?? false,
      isForumOwner: json["is_forum_owner"] ?? false,
    );
  }
  
  ForumReply copyWith({
    int? id,
    String? username,
    String? content,
    int? likes,
    DateTime? createdAt,
    bool? userHasLiked,
    bool? isOwner,
    bool? isForumOwner,
  }) {
    return ForumReply(
      id: id ?? this.id,
      username: username ?? this.username,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      userHasLiked: userHasLiked ?? this.userHasLiked,
      isOwner: isOwner ?? this.isOwner,
      isForumOwner: isForumOwner ?? this.isForumOwner,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "content": content,
    "likes": likes,
    "created_at": createdAt.toIso8601String(),
    "user_has_liked": userHasLiked,
    "is_owner": isOwner,
    "is_forum_owner": isForumOwner,
  };
}

List<ForumReply> forumReplyFromJson(String str) {
  final List<dynamic> jsonList = json.decode(str);
  return jsonList.map((json) => ForumReply.fromJson(json)).toList();
}

String forumReplyToJson(List<ForumReply> data) {
  final List<Map<String, dynamic>> jsonList = data.map((reply) => reply.toJson()).toList();
  return json.encode(jsonList);
}