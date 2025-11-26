import 'dart:convert';

TeamsStandingsEntry teamsStandingsEntryFromJson(String str) => TeamsStandingsEntry.fromJson(json.decode(str));

String teamsStandingsEntryToJson(TeamsStandingsEntry data) => json.encode(data.toJson());

class TeamsStandingsEntry {
    int season;
    List<Datum> data;

    TeamsStandingsEntry({
        required this.season,
        required this.data,
    });

    factory TeamsStandingsEntry.fromJson(Map<String, dynamic> json) => TeamsStandingsEntry(
        season: json["season"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "season": season,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String team;
    int points;
    int wins;
    int gpPoints;
    int sprintPoints;
    String url;

    Datum({
        required this.team,
        required this.points,
        required this.wins,
        required this.gpPoints,
        required this.sprintPoints,
        required this.url,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        team: json["team"],
        points: json["points"],
        wins: json["wins"],
        gpPoints: json["gp_points"],
        sprintPoints: json["sprint_points"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "team": team,
        "points": points,
        "wins": wins,
        "gp_points": gpPoints,
        "sprint_points": sprintPoints,
        "url": url,
    };
}
