// To parse this JSON data, do
//
//     final forumsEntry = forumsEntryFromJson(jsonString);

import 'dart:convert';

ForumsEntry forumsEntryFromJson(String str) => ForumsEntry.fromJson(json.decode(str));

String forumsEntryToJson(ForumsEntry data) => json.encode(data.toJson());

class ForumsEntry {
    int count;
    int numPages;
    int page;
    List<Result> results;

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
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "count": count,
        "num_pages": numPages,
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    String id;
    String title;
    String content;
    DateTime createdAt;
    int forumsViews;
    int forumsRepliesCounts;
    bool isHot;
    String author;

    Result({
        required this.id,
        required this.title,
        required this.content,
        required this.createdAt,
        required this.forumsViews,
        required this.forumsRepliesCounts,
        required this.isHot,
        required this.author,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
        forumsViews: json["forums_views"],
        forumsRepliesCounts: json["forums_replies_counts"],
        isHot: json["is_hot"],
        author: json["author"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "created_at": createdAt.toIso8601String(),
        "forums_views": forumsViews,
        "forums_replies_counts": forumsRepliesCounts,
        "is_hot": isHot,
        "author": author,
    };
}
