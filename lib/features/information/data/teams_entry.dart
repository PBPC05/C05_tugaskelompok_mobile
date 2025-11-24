import 'dart:convert';

List<TeansEntry> teansEntryFromJson(String str) => List<TeansEntry>.from(json.decode(str).map((x) => TeansEntry.fromJson(x)));

String teansEntryToJson(List<TeansEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TeansEntry {
    String name;
    String fullName;
    String base;
    String teamChief;
    String technicalChief;
    String chassis;
    String powerUnit;
    int firstTeamEntry;
    int worldChampionships;
    String highestRaceFinish;
    int polePositions;
    int fastestLaps;
    String color;
    String teamLogo;
    String url;

    TeansEntry({
        required this.name,
        required this.fullName,
        required this.base,
        required this.teamChief,
        required this.technicalChief,
        required this.chassis,
        required this.powerUnit,
        required this.firstTeamEntry,
        required this.worldChampionships,
        required this.highestRaceFinish,
        required this.polePositions,
        required this.fastestLaps,
        required this.color,
        required this.teamLogo,
        required this.url,
    });

    factory TeansEntry.fromJson(Map<String, dynamic> json) => TeansEntry(
        name: json["name"],
        fullName: json["full_name"],
        base: json["base"],
        teamChief: json["team_chief"],
        technicalChief: json["technical_chief"],
        chassis: json["chassis"],
        powerUnit: json["power_unit"],
        firstTeamEntry: json["first_team_entry"],
        worldChampionships: json["world_championships"],
        highestRaceFinish: json["highest_race_finish"],
        polePositions: json["pole_positions"],
        fastestLaps: json["fastest_laps"],
        color: json["color"],
        teamLogo: json["team_logo"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "full_name": fullName,
        "base": base,
        "team_chief": teamChief,
        "technical_chief": technicalChief,
        "chassis": chassis,
        "power_unit": powerUnit,
        "first_team_entry": firstTeamEntry,
        "world_championships": worldChampionships,
        "highest_race_finish": highestRaceFinish,
        "pole_positions": polePositions,
        "fastest_laps": fastestLaps,
        "color": color,
        "team_logo": teamLogo,
        "url": url,
    };
}