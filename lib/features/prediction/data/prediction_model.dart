// To parse this JSON data, do
//
//     final vote = voteFromJson(jsonString);

import 'dart:convert';

List<Vote> voteFromJson(String str) => List<Vote>.from(json.decode(str).map((x) => Vote.fromJson(x)));

String voteToJson(List<Vote> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vote {
    String voteType;
    String race;
    String content;

    Vote({
        required this.voteType,
        required this.race,
        required this.content,
    });

    factory Vote.fromJson(Map<String, dynamic> json) => Vote(
        voteType: json['vote_type'],
        race: json["race"],
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "vote_type": voteType,
        "race": race,
        "content": content,
    };
}