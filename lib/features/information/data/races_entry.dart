// To parse this JSON data, do
//
//     final racesEntry = racesEntryFromJson(jsonString);

import 'dart:convert';

RacesEntry racesEntryFromJson(String str) => RacesEntry.fromJson(json.decode(str));

String racesEntryToJson(RacesEntry data) => json.encode(data.toJson());

class RacesEntry {
    int season;
    int round;
    String slug;
    String name;
    String date;
    String circuit;
    String country;
    String url;
    bool hasResults;
    int resultCount;
    List<Result> results;

    RacesEntry({
        required this.season,
        required this.round,
        required this.slug,
        required this.name,
        required this.date,
        required this.circuit,
        required this.country,
        required this.url,
        required this.hasResults,
        required this.resultCount,
        required this.results,
    });

    factory RacesEntry.fromJson(Map<String, dynamic> json) => RacesEntry(
        season: json["season"],
        round: json["round"],
        slug: json["slug"],
        name: json["name"],
        date: json["date"],
        circuit: json["circuit"],
        country: json["country"],
        url: json["url"],
        hasResults: json["has_results"],
        resultCount: json["result_count"],
        results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "season": season,
        "round": round,
        "slug": slug,
        "name": name,
        "date": date,
        "circuit": circuit,
        "country": country,
        "url": url,
        "has_results": hasResults,
        "result_count": resultCount,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Result {
    int? position;
    Status status;
    int grid;
    int laps;
    String timeText;
    double points;
    bool fastestLap;
    Driver driver;
    Team team;

    Result({
        required this.position,
        required this.status,
        required this.grid,
        required this.laps,
        required this.timeText,
        required this.points,
        required this.fastestLap,
        required this.driver,
        required this.team,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        position: json["position"],
        status: statusValues.map[json["status"]]!,
        grid: json["grid"],
        laps: json["laps"],
        timeText: json["time_text"],
        points: (json['points'] as num).toDouble(),
        fastestLap: json["fastest_lap"],
        driver: Driver.fromJson(json["driver"]),
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "position": position,
        "status": statusValues.reverse[status],
        "grid": grid,
        "laps": laps,
        "time_text": timeText,
        "points": points,
        "fastest_lap": fastestLap,
        "driver": driver.toJson(),
        "team": team.toJson(),
    };
}

class Driver {
    String fullName;
    int number;
    String abbreviation;
    String url;
    String numberImage;
    String driverImage;

    Driver({
        required this.fullName,
        required this.number,
        required this.abbreviation,
        required this.url,
        required this.numberImage,
        required this.driverImage,
    });

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        fullName: json["full_name"],
        number: json["number"],
        abbreviation: json["abbreviation"],
        url: json["url"],
        numberImage: json["number_image"],
        driverImage: json["driver_image"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "number": number,
        "abbreviation": abbreviation,
        "url": url,
        "number_image": numberImage,
        "driver_image": driverImage,
    };
}

enum Status {
    FINISHED,
    NC,
    DQ
}

final statusValues = EnumValues({
    "FINISHED": Status.FINISHED,
    "NC": Status.NC,
    "DQ": Status.DQ,
});

class Team {
    String name;
    String color;
    String url;
    String logo;

    Team({
        required this.name,
        required this.color,
        required this.url,
        required this.logo,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        name: json["name"],
        color: json["color"],
        url: json["url"],
        logo: json["logo"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "color": color,
        "url": url,
        "logo": logo,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
