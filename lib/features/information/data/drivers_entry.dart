import 'dart:convert';

List<DriversEntry> driversEntryFromJson(String str) => List<DriversEntry>.from(json.decode(str).map((x) => DriversEntry.fromJson(x)));

String driversEntryToJson(List<DriversEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriversEntry {
    String fullName;
    String abbreviation;
    int number;
    String team;
    String country;
    int podiums;
    double points;
    int grandsPrixEntered;
    int worldChampionships;
    String highestRaceFinish;
    String highestGridPosition;
    String dateOfBirth;
    String placeOfBirth;
    String numberImage;
    String driverImage;
    String color;
    String url;

    DriversEntry({
        required this.fullName,
        required this.abbreviation,
        required this.number,
        required this.team,
        required this.country,
        required this.podiums,
        required this.points,
        required this.grandsPrixEntered,
        required this.worldChampionships,
        required this.highestRaceFinish,
        required this.highestGridPosition,
        required this.dateOfBirth,
        required this.placeOfBirth,
        required this.numberImage,
        required this.driverImage,
        required this.color,
        required this.url,
    });

    factory DriversEntry.fromJson(Map<String, dynamic> json) => DriversEntry(
        fullName: json["full_name"],
        abbreviation: json["abbreviation"],
        number: json["number"],
        team: json["team"],
        country: json["country"],
        podiums: json["podiums"],
        points: json["points"]?.toDouble(),
        grandsPrixEntered: json["grands_prix_entered"],
        worldChampionships: json["world_championships"],
        highestRaceFinish: json["highest_race_finish"],
        highestGridPosition: json["highest_grid_position"],
        dateOfBirth: json["date_of_birth"],
        placeOfBirth: json["place_of_birth"],
        numberImage: json["number_image"],
        driverImage: json["driver_image"],
        color: json["color"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "abbreviation": abbreviation,
        "number": number,
        "team": team,
        "country": country,
        "podiums": podiums,
        "points": points,
        "grands_prix_entered": grandsPrixEntered,
        "world_championships": worldChampionships,
        "highest_race_finish": highestRaceFinish,
        "highest_grid_position": highestGridPosition,
        "date_of_birth": dateOfBirth,
        "place_of_birth": placeOfBirth,
        "number_image": numberImage,
        "driver_image": driverImage,
        "color": color,
        "url": url,
    };
}