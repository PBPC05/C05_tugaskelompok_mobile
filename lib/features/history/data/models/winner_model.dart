class Winner {
  final int id;
  final String grandPrix;
  final String date;       // format yyyy-mm-dd
  final String winner;     // nama winner nya
  final String car;
  final double? laps;
  final String time;
  final String? nameCode;
  final String imageUrl;

  Winner({
    required this.id,
    required this.grandPrix,
    required this.date,
    required this.winner,
    required this.car,
    required this.laps,
    required this.time,
    required this.nameCode,
    required this.imageUrl,
  });

  /// Parsing JSON dari Django
  factory Winner.fromJson(Map<String, dynamic> json) {
    final f = json["fields"] ?? {};

    return Winner(
      id: json["pk"],
      grandPrix: f["grand_prix"] ?? "",
      date: f["date"] ?? "",
      winner: f["winner"] ?? "",
      car: f["car"] ?? "",
      laps: f["laps"] != null ? (f["laps"] as num).toDouble() : null,
      time: f["time"] ?? "",
      nameCode: f["name_code"],
      imageUrl: f["image_url"] ?? "",
    );
  }

  // ========================================================
  // Getter tambahan (biar tidak error di winner_table.dart)
  // ========================================================

  /// Sama seperti Driver -> driverName
  String get winnerName => winner;

  /// Convert tanggal "2023-10-12" → "12 Oct 2023" (lebih rapi)
  String get dateString {
    try {
      final d = DateTime.parse(date);
      return "${d.day} ${_monthName(d.month)} ${d.year}";
    } catch (_) {
      return date; // fallback
    }
  }

  String _monthName(int m) {
    const names = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return names[m];
  }
}
