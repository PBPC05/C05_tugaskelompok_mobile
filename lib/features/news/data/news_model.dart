// To parse this JSON data, do
//
//     final news = newsFromJson(jsonString);

import 'dart:convert';

News newsFromJson(String str) => News.fromJson(json.decode(str));

String newsToJson(News data) => json.encode(data.toJson());

class News {
    String username;
    String id;
    String title;
    String content;
    String category;
    String thumbnail;
    int newsViews;
    int newsComments;
    DateTime createdAt;
    bool isFeatured;

    News({
        required this.username,
        required this.id,
        required this.title,
        required this.content,
        required this.category,
        required this.thumbnail,
        required this.newsViews,
        required this.newsComments,
        required this.createdAt,
        required this.isFeatured,
    });

    factory News.fromJson(Map<String, dynamic> json) => News(
        username: json["username"],
        id: json["id"],
        title: json["title"],
        content: json["content"],
        category: json["category"],
        thumbnail: json["thumbnail"],
        newsViews: json["news_views"],
        newsComments: json["news_comments"],
        createdAt: DateTime.parse(json["created_at"]),
        isFeatured: json["is_featured"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "id": id,
        "title": title,
        "content": content,
        "category": category,
        "thumbnail": thumbnail,
        "news_views": newsViews,
        "news_comments": newsComments,
        "created_at": createdAt.toIso8601String(),
        "is_featured": isFeatured,
    };
}
