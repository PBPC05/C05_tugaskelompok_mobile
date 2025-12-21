import 'package:flutter/material.dart';
import '../../data/models/winner_model.dart';

class WinnerFilter extends StatefulWidget {
  final List<Winner> allWinners;
  final void Function(List<Winner>) onChanged;
  final VoidCallback? onReset;

  const WinnerFilter({super.key, required this.allWinners, required this.onChanged, this.onReset});

  @override
  State<WinnerFilter> createState() => _WinnerFilterState();
}

class _WinnerFilterState extends State<WinnerFilter> {
  String filterType = "";
  final TextEditingController _ctrl = TextEditingController();

  void applyFilter() {
    final q = _ctrl.text.toLowerCase().trim();
    final type = filterType;
    final results = widget.allWinners.where((w) {
      final cols = {
        "winner": w.winnerName.toLowerCase(),
        "car": w.car.toLowerCase(),
        "grand_prix": w.grandPrix.toLowerCase(),
        "date": w.date.toLowerCase(),
      };
      if (type.isEmpty) {
        // cari di semua kolom
        return cols.values.any((v) => v.contains(q));
      }
      return cols[type]?.contains(q) ?? false;
    }).toList();
    widget.onChanged(results);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Winners", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<String>(
                value: filterType.isEmpty ? null : filterType,
                dropdownColor: Colors.grey.shade800,
                hint: const Text("-- Filter By --", style: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: "", child: Text("All", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "winner", child: Text("Winner", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "car", child: Text("Car", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "grand_prix", child: Text("Grand Prix", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "date", child: Text("Date", style: TextStyle(color: Colors.white))),
                ],
                onChanged: (v) {
                  setState(() => filterType = v ?? "");
                  applyFilter();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type to filter...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _ctrl.clear();
                        widget.onChanged(List.from(widget.allWinners));
                        if (widget.onReset != null) widget.onReset!();
                      },
                    ),
                  ),
                  onChanged: (_) => applyFilter(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _ctrl.clear();
                  setState(() => filterType = "");
                  widget.onChanged(List.from(widget.allWinners));
                  if (widget.onReset != null) widget.onReset!();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade700),
                child: const Text("Reset", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
