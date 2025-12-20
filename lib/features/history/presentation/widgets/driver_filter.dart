import 'package:flutter/material.dart';
import '../../data/models/driver_model.dart';

class DriverFilter extends StatefulWidget {
  final List<Driver> allDrivers;
  final Function(List<Driver>) onChanged;
  final VoidCallback onReset;

  const DriverFilter({
    super.key,
    required this.allDrivers,
    required this.onChanged,
    required this.onReset,
  });

  @override
  State<DriverFilter> createState() => _DriverFilterState();
}

class _DriverFilterState extends State<DriverFilter> {
  String filterType = "";
  final TextEditingController _ctrl = TextEditingController();

  void applyFilter() {
    final q = _ctrl.text.toLowerCase().trim();

    final results = widget.allDrivers.where((d) {
      final fields = {
        "driver": d.driverName.toLowerCase(),
        "nationality": d.nationality.toLowerCase(),
        "car": d.car.toLowerCase(),
        "year": d.year.toString(),
      };

      if (filterType.isEmpty) {
        return fields.values.any((v) => v.contains(q));
      }

      return fields[filterType]!.contains(q);
    }).toList();

    widget.onChanged(results);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Drivers",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          Row(
            children: [
              DropdownButton<String>(
                value: filterType.isEmpty ? null : filterType,
                dropdownColor: Colors.grey.shade800,
                hint: const Text("-- Filter By --", style: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: "", child: Text("All", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "driver", child: Text("Driver", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "nationality", child: Text("Nationality", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "car", child: Text("Car", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "year", child: Text("Year", style: TextStyle(color: Colors.white))),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _ctrl.clear();
                        widget.onReset();
                        widget.onChanged(List.from(widget.allDrivers));
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
                  widget.onReset();
                  widget.onChanged(List.from(widget.allDrivers));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Reset"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
