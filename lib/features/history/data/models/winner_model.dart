// lib/features/history/data/models/winner_model.dart
class Winner {
  final int id;
  final String grandPrix;
  final String date; // store as ISO string
  final String winner;
  final String car;
  final double? laps;
  final String time;
  final String? nameCode;
  final String? imageUrl;

  Winner({
    required this.id,
    required this.grandPrix,
    required this.date,
    required this.winner,
    required this.car,
    this.laps,
    required this.time,
    this.nameCode,
    this.imageUrl,
  });

  factory Winner.fromJson(Map<String, dynamic> json) {
    return Winner(
      id: json['id'] as int,
      grandPrix: (json['grand_prix'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      winner: (json['winner'] ?? '') as String,
      car: (json['car'] ?? '') as String,
      laps: json['laps'] != null ? double.tryParse(json['laps'].toString()) : null,
      time: (json['time'] ?? '') as String,
      nameCode: json['name_code'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grand_prix': grandPrix,
      'date': date,
      'winner': winner,
      'car': car,
      'laps': laps,
      'time': time,
      'name_code': nameCode,
      'image_url': imageUrl,
    };
  }
}
