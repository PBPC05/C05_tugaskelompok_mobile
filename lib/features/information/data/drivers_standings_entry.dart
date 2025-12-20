import 'dart:convert';

DriversStandingsEntry driversStandingsEntryFromJson(String str) => DriversStandingsEntry.fromJson(json.decode(str));

String driversStandingsEntryToJson(DriversStandingsEntry data) => json.encode(data.toJson());

class DriversStandingsEntry {
    int season;
    List<Datum> data;

    DriversStandingsEntry({
        required this.season,
        required this.data,
    });

    factory DriversStandingsEntry.fromJson(Map<String, dynamic> json) => DriversStandingsEntry(
        season: json["season"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "season": season,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String driver;
    String team;
    int points;
    int wins;
    int gpPoints;
    int sprintPoints;
    String url;

    Datum({
        required this.driver,
        required this.team,
        required this.points,
        required this.wins,
        required this.gpPoints,
        required this.sprintPoints,
        required this.url,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        driver: json["driver"],
        team: json["team"],
        points: (json["points"] as num).toInt(), 
        wins: (json["wins"] as num).toInt(),
        gpPoints: (json["gp_points"] as num).toInt(),
        sprintPoints: (json["sprint_points"] as num).toInt(),
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "driver": driver,
        "team": team,
        "points": points,
        "wins": wins,
        "gp_points": gpPoints,
        "sprint_points": sprintPoints,
        "url": url,
    };
}