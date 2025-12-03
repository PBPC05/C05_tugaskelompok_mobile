import 'dart:convert';

// ===============================
// Forums Pagination Entry
// ===============================

ForumsEntry forumsEntryFromJson(String str) =>
    ForumsEntry.fromJson(json.decode(str));

String forumsEntryToJson(ForumsEntry data) => json.encode(data.toJson());

class ForumsEntry {
  int count;
  int numPages;
  int page;
  List<ForumResult> results;

  ForumsEntry({
    required this.count,
    required this.numPages,
    required this.page,
    required this.results,
  });

  factory ForumsEntry.fromJson(Map<String, dynamic> json) => ForumsEntry(
        count: json["count"],
        numPages: json["num_pages"],
        page: json["page"],
        results: List<ForumResult>.from(
          json["results"].map((x) => ForumResult.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "num_pages": numPages,
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

// ===============================
// Forum Item
// ===============================

class ForumResult {
  String forumsId;
  String title;
  String content;
  int forumsViews;
  int forumsRepliesCounts;
  bool isHot;
  DateTime createdAt;
  DateTime updatedAt;

  List<int> forumsLikes;
  Author user;

  ForumResult({
    required this.forumsId,
    required this.title,
    required this.content,
    required this.forumsViews,
    required this.forumsRepliesCounts,
    required this.isHot,
    required this.createdAt,
    required this.updatedAt,
    required this.forumsLikes,
    required this.user,
  });

  factory ForumResult.fromJson(Map<String, dynamic> json) => ForumResult(
        forumsId: json["forums_id"],
        title: json["title"],
        content: json["content"],
        forumsViews: json["forums_views"],
        forumsRepliesCounts: json["forums_replies_counts"],
        isHot: json["is_hot"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        forumsLikes: List<int>.from(json["forums_likes"].map((x) => x)),
        user: Author.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "forums_id": forumsId,
        "title": title,
        "content": content,
        "forums_views": forumsViews,
        "forums_replies_counts": forumsRepliesCounts,
        "is_hot": isHot,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "forums_likes": List<dynamic>.from(forumsLikes.map((x) => x)),
        "user": user.toJson(),
      };
}

// ===============================
// Replies Pagination Entry
// ===============================

class RepliesEntry {
  int count;
  int numPages;
  int page;
  List<ReplyResult> results;

  RepliesEntry({
    required this.count,
    required this.numPages,
    required this.page,
    required this.results,
  });

  factory RepliesEntry.fromJson(Map<String, dynamic> json) => RepliesEntry(
        count: json["count"],
        numPages: json["num_pages"],
        page: json["page"],
        results: List<ReplyResult>.from(
          json["results"].map((x) => ReplyResult.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "num_pages": numPages,
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

// ===============================
// Reply Item
// ===============================

class ReplyResult {
  int id;
  String forums; // UUID string
  String repliesContent;
  DateTime createdAt;
  List<int> repliesLikes;
  Author user;

  ReplyResult({
    required this.id,
    required this.forums,
    required this.repliesContent,
    required this.createdAt,
    required this.repliesLikes,
    required this.user,
  });

  factory ReplyResult.fromJson(Map<String, dynamic> json) => ReplyResult(
        id: json["id"],
        forums: json["forums"],
        repliesContent: json["replies_content"],
        createdAt: DateTime.parse(json["created_at"]),
        repliesLikes:
            List<int>.from(json["forums_replies_likes"].map((x) => x)),
        user: Author.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "forums": forums,
        "replies_content": repliesContent,
        "created_at": createdAt.toIso8601String(),
        "forums_replies_likes":
            List<dynamic>.from(repliesLikes.map((x) => x)),
        "user": user.toJson(),
      };
}

// ===============================
// Author (User Minimal Data)
// ===============================

class Author {
  int id;
  String username;

  Author({
    required this.id,
    required this.username,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: json["id"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
      };
}
