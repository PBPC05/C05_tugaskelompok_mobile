class Driver {
  final int id;
  final String driverName;
  final String nationality;
  final String car;
  final double points;
  final int podiums;
  final int year;
  final String? imageUrl;

  Driver({
    required this.id,
    required this.driverName,
    required this.nationality,
    required this.car,
    required this.points,
    required this.podiums,
    required this.year,
    this.imageUrl,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    final fields = json["fields"];

    return Driver(
      id: json["pk"],
      driverName: fields["driver_name"] ?? "",
      nationality: fields["nationality"] ?? "",
      car: fields["car"] ?? "",
      points: (fields["points"] as num).toDouble(),
      podiums: fields["podiums"] ?? 0,

      // FIX: supaya tidak passing null ke compareTo
      year: fields["year"] ?? 0,

      imageUrl: fields["image_url"],
    );
  }
}
