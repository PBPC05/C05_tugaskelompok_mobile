import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../data/models/driver_model.dart';

class DriverEditModal extends StatefulWidget {
  final Driver driver;
  final Future<void> Function() onUpdated;

  const DriverEditModal({
    super.key,
    required this.driver,
    required this.onUpdated,
  });

  @override
  State<DriverEditModal> createState() => _DriverEditModalState();
}

class _DriverEditModalState extends State<DriverEditModal> {
  final _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> input;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    input = {
      "driver_name": widget.driver.driverName,
      "nationality": widget.driver.nationality,
      "car": widget.driver.car,
      "points": widget.driver.points,
      "podiums": widget.driver.podiums,
      "year": widget.driver.year,
      "image_url": widget.driver.imageUrl ?? "",
    };
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => saving = true);

    final url = Uri.parse("http://localhost:8000/history/driver/edit/${widget.driver.id}/");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(input),
    );

    setState(() => saving = false);

    widget.onUpdated();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: const Text("Edit Driver", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field("Driver Name", "driver_name"),
              _field("Nationality", "nationality"),
              _field("Car", "car"),
              _field("Points", "points", number: true),
              _field("Podiums", "podiums", number: true),
              _field("Year", "year", number: true),
              _field("Image URL", "image_url"),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: saving ? null : submit,
          child: saving ? const CircularProgressIndicator() : const Text("Save"),
        ),
      ],
    );
  }

  Widget _field(String label, String key, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: input[key].toString(),
        style: const TextStyle(color: Colors.white),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade800,
        ),
        onSaved: (v) {
          if (number) {
            input[key] = double.tryParse(v!) ?? 0;
          } else {
            input[key] = v ?? "";
          }
        },
      ),
    );
  }
}
