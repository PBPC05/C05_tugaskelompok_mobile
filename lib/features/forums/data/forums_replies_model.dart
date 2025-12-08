import 'dart:convert';

List<ForumReply> forumReplyFromJson(String str) => List<ForumReply>.from(json.decode(str).map((x) => ForumReply.fromJson(x)));

String forumReplyToJson(List<ForumReply> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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

    factory ForumReply.fromJson(Map<String, dynamic> json) => ForumReply(
        id: json["id"],
        username: json["username"],
        content: json["content"],
        likes: json["likes"],
        createdAt: DateTime.parse(json["created_at"]),
        userHasLiked: json["user_has_liked"],
        isOwner: json["is_owner"],
        isForumOwner: json["is_forum_owner"],
    );

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
