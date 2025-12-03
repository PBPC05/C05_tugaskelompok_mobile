import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/history_api.dart';

class DriverCarousel extends StatefulWidget {
  final List<Driver> drivers;
  final bool showControls;

  const DriverCarousel({
    super.key,
    required this.drivers,
    this.showControls = true,
  });

  @override
  State<DriverCarousel> createState() => _DriverCarouselState();
}

class _DriverCarouselState extends State<DriverCarousel> {
  int index = 0;
  final api = HistoryApi();

  void next() {
    if (widget.drivers.isEmpty) return;
    setState(() => index = (index + 1) % widget.drivers.length);
  }

  void prev() {
    if (widget.drivers.isEmpty) return;
    setState(() => index = (index - 1 + widget.drivers.length) % widget.drivers.length);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drivers.isEmpty) {
      return const Text("No drivers available", style: TextStyle(color: Colors.white));
    }

    final d = widget.drivers[index];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent),
          ),
          child: Row(
            children: [
              // image
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade800,
                ),
                child: (d.imageUrl != null && d.imageUrl!.isNotEmpty)
                    ? Image.network(
                        api.proxiedImage(d.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.white54),
                      )
                    : const Icon(Icons.person, color: Colors.white54, size: 48),
              ),

              const SizedBox(width: 16),

              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.driverName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Nationality: ${d.nationality}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Car: ${d.car}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Points: ${d.points}",
                        style: const TextStyle(color: Colors.redAccent)),
                    Text("Podiums: ${d.podiums}",
                        style: const TextStyle(color: Colors.redAccent)),
                    Text("Year: ${d.year}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Controls hanya muncul kalo admin nya TIDAK mematikannya (showControls == true)
        if (widget.showControls)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: prev),
              const SizedBox(width: 12),
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: next),
            ],
          ),
      ],
    );
  }
}
