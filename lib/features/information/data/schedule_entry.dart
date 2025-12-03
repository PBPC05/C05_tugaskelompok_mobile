// To parse this JSON data, do
//
//     final scheduleEntry = scheduleEntryFromJson(jsonString);

import 'dart:convert';

ScheduleEntry scheduleEntryFromJson(String str) => ScheduleEntry.fromJson(json.decode(str));

String scheduleEntryToJson(ScheduleEntry data) => json.encode(data.toJson());

class ScheduleEntry {
    int season;
    List<Race> data;

    ScheduleEntry({
        required this.season,
        required this.data,
    });

    factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
        season: json["season"],
        data: List<Race>.from(json["data"].map((x) => Race.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "season": season,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Race {
    int season;
    int roundNumber;
    String name;
    String circuit;
    DateTime date;
    String url;

    Race({
        required this.season,
        required this.roundNumber,
        required this.name,
        required this.circuit,
        required this.date,
        required this.url,
    });

    factory Race.fromJson(Map<String, dynamic> json) => Race(
        season: json["season"],
        roundNumber: json["round_number"],
        name: json["name"],
        circuit: json["circuit"],
        date: DateTime.parse(json["date"]),
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "season": season,
        "round_number": roundNumber,
        "name": name,
        "circuit": circuit,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "url": url,
    };
}
