import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/driver_model.dart';
import 'dart:convert';

class DriverEditModal extends StatefulWidget {
  final Driver driver;
  final Future<void> Function() onUpdated;

  const DriverEditModal({super.key, required this.driver, required this.onUpdated});

  @override
  State<DriverEditModal> createState() => _DriverEditModalState();
}

class _DriverEditModalState extends State<DriverEditModal> {
  final Map<String, TextEditingController> c = {};

  @override
  void initState() {
    super.initState();
    c["driver_name"] = TextEditingController(text: widget.driver.driverName);
    c["nationality"] = TextEditingController(text: widget.driver.nationality);
    c["car"] = TextEditingController(text: widget.driver.car);
    c["points"] = TextEditingController(text: widget.driver.points.toString());
    c["podiums"] = TextEditingController(text: widget.driver.podiums.toString());
    c["year"] = TextEditingController(text: widget.driver.year.toString());
    c["image_url"] = TextEditingController(text: widget.driver.imageUrl ?? "");
  }

  Future<void> submit() async {
    // Pake localhostnya ntar diganti pakai pws
    final url = Uri.parse(
        "http://localhost:8000/history/driver/edit/${widget.driver.id}/");

    await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driver_name": c["driver_name"]!.text,
          "nationality": c["nationality"]!.text,
          "car": c["car"]!.text,
          "points": double.tryParse(c["points"]!.text) ?? 0,
          "podiums": int.tryParse(c["podiums"]!.text) ?? 0,
          "year": int.tryParse(c["year"]!.text) ?? 0,
          "image_url": c["image_url"]!.text,
        }));

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text("Edit Driver", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          children: c.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: e.value,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: e.key,
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey.shade800),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent))),
        TextButton(
            onPressed: submit,
            child: const Text("Save", style: TextStyle(color: Colors.greenAccent))),
      ],
    );
  }
}
