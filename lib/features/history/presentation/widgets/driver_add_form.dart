import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverAddForm extends StatefulWidget {
  final Function onAdded;

  const DriverAddForm({super.key, required this.onAdded});

  @override
  State<DriverAddForm> createState() => _DriverAddFormState();
}

class _DriverAddFormState extends State<DriverAddForm> {
  final formKey = GlobalKey<FormState>();
  final Map<String, dynamic> input = {};

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    formKey.currentState!.save();

    // Pake localhost nya ntar diganti pake pws
    final url = Uri.parse("http://localhost:8000/history/driver/add/");
    await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(input));

    widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text("Add Driver",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            buildField("driver_name", "Driver Name"),
            buildField("nationality", "Nationality"),
            buildField("car", "Car"),
            buildField("points", "Points", number: true),
            buildField("podiums", "Podiums", number: true),
            buildField("year", "Year", number: true),
            buildField("image_url", "Image URL"),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildField(String key, String label, {bool number = false}) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
      keyboardType: number ? TextInputType.number : TextInputType.text,
      onSaved: (v) => input[key] = number ? num.parse(v ?? "0") : v,
    );
  }
}
