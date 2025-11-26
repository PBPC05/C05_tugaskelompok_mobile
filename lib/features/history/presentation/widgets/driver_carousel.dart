import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';
import '../../data/history_api.dart';

class DriverCarousel extends StatefulWidget {
  final List<Driver> drivers;

  const DriverCarousel({super.key, required this.drivers});

  @override
  State<DriverCarousel> createState() => _DriverCarouselState();
}

class _DriverCarouselState extends State<DriverCarousel> {
  int index = 0;
  final HistoryApi api = HistoryApi(); // untuk proxy image

  void next() {
    if (widget.drivers.isEmpty) return;
    setState(() {
      index = (index + 1) % widget.drivers.length;
    });
  }

  void prev() {
    if (widget.drivers.isEmpty) return;
    setState(() {
      index = (index - 1 + widget.drivers.length) % widget.drivers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.drivers.isEmpty) {
      return const Center(
        child: Text(
          "No drivers available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final driver = widget.drivers[index];

    return Column(
      children: [
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent),
          ),
          child: Row(
            children: [
              // ==== FOTO DRIVER (pakai proxy) ====
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade800,
                ),
                child: (driver.imageUrl != null && driver.imageUrl!.isNotEmpty)
                    ? Image.network(
                        api.proxiedImage(driver.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 40,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
              ),

              const SizedBox(width: 20),

              // ==== INFO DRIVER ====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      driver.driverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Nationality: ${driver.nationality}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Car: ${driver.car}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Points: ${driver.points}",
                        style: const TextStyle(color: Colors.yellowAccent)),
                    Text("Podiums: ${driver.podiums}",
                        style: const TextStyle(color: Colors.yellowAccent)),
                    Text("Year: ${driver.year}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ==== BUTTON NEXT / PREV ====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: prev,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: next,
            ),
          ],
        )
      ],
    );
  }
}
