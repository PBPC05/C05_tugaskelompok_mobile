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
  final TextEditingController searchController = TextEditingController();

  void applyFilter(String query) {
    final q = query.toLowerCase();
    final filtered = widget.allDrivers.where((d) {
      return d.driverName.toLowerCase().contains(q) ||
          d.nationality.toLowerCase().contains(q) ||
          d.car.toLowerCase().contains(q);
    }).toList();

    widget.onChanged(filtered);
  }

  void resetFilter() {
    searchController.clear();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: applyFilter,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                hintText: "Cari driver...",
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: resetFilter,
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
