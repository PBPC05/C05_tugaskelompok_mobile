import 'package:flutter/material.dart';
import '../../data/history_api.dart';

class DriverAddForm extends StatefulWidget {
  final VoidCallback onAdded;

  const DriverAddForm({super.key, required this.onAdded});

  @override
  State<DriverAddForm> createState() => _DriverAddFormState();
}

class _DriverAddFormState extends State<DriverAddForm> {
  final _formKey = GlobalKey<FormState>();
  final api = HistoryApi();

  String name = "";
  String nationality = "";
  String car = "";
  double points = 0;
  int podiums = 0;
  int year = 0;
  String imageUrl = "";

  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Add Driver", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),

            _field("Driver Name", (v) => name = v!, required: true),
            _field("Nationality", (v) => nationality = v!, required: true),
            _field("Car", (v) => car = v!, required: true),

            _field("Points", (v) => points = double.tryParse(v!) ?? 0, number: true),
            _field("Podiums", (v) => podiums = int.tryParse(v!) ?? 0, number: true),
            _field("Year", (v) => year = int.tryParse(v!) ?? 0, number: true),

            _field("Image URL (optional)", (v) => imageUrl = v!,
                validator: (v) {
                  if (v != null && v.isNotEmpty && Uri.tryParse(v)?.isAbsolute == false) {
                    return "Invalid image URL!";
                  }
                  return null;
                }
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: saving ? null : save,
              child: saving
                  ? const CircularProgressIndicator()
                  : const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, Function(String?) onChanged,
      {bool required = false, bool number = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: validator ??
            (required
                ? (v) => v == null || v.isEmpty ? "$label required!" : null
                : null),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "driver_name": name,
      "nationality": nationality,
      "car": car,
      "points": points,
      "podiums": podiums,
      "year": year,
      "image_url": imageUrl,
    };

    setState(() => saving = true);

    final success = await api.addDriver(data);

    if (!mounted) return;

    if (success) {
      widget.onAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver added successfully!")),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add driver")),
      );
    }

    setState(() => saving = false);
  }
}
