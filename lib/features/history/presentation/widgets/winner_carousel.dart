import 'package:flutter/material.dart';
import '../../data/models/winner_model.dart';

typedef ProxyFn = String Function(String? url);

class WinnerCarousel extends StatefulWidget {
  final List<Winner> winners;
  final ProxyFn imageProxy;
  final bool showControls;

  const WinnerCarousel({
    super.key,
    required this.winners,
    required this.imageProxy,
    this.showControls = true,
  });

  @override
  State<WinnerCarousel> createState() => _WinnerCarouselState();
}

class _WinnerCarouselState extends State<WinnerCarousel> {
  int index = 0;

  void next() {
    if (widget.winners.isEmpty) return;
    setState(() => index = (index + 1) % widget.winners.length);
  }

  void prev() {
    if (widget.winners.isEmpty) return;
    setState(() => index = (index - 1 + widget.winners.length) % widget.winners.length);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.winners.isEmpty) {
      return const Center(child: Text("No winners available", style: TextStyle(color: Colors.white)));
    }

    final w = widget.winners[index];
    final imgUrl = w.imageUrl.isNotEmpty ? widget.imageProxy(w.imageUrl) : "";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.yellow.shade700),
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
                child: imgUrl.isNotEmpty
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54),
                      )
                    : const Icon(Icons.flag, color: Colors.white54, size: 48),
              ),
              const SizedBox(width: 16),
              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.winnerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Grand Prix: ${w.grandPrix}", style: const TextStyle(color: Colors.white70)),
                    Text("Car: ${w.car}", style: const TextStyle(color: Colors.white70)),
                    Text("Date: ${w.dateString}", style: const TextStyle(color: Colors.yellowAccent)),
                    Text("Laps: ${w.laps ?? '-'}", style: const TextStyle(color: Colors.white70)),
                    Text("Time: ${w.time}", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (widget.showControls)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: prev),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white), onPressed: next),
            ],
          ),
      ],
    );
  }
}
