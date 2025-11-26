import 'package:flutter/material.dart';
import '../../data/history_api.dart';

class DriverAddForm extends StatefulWidget {
  final Function onAdded; // callback setelah berhasil tambah data

  const DriverAddForm({super.key, required this.onAdded});

  @override
  State<DriverAddForm> createState() => _DriverAddFormState();
}

class _DriverAddFormState extends State<DriverAddForm> {
  final _formKey = GlobalKey<FormState>();
  final HistoryApi api = HistoryApi();

  // Variabel input driver
  String _name = "";
  String _nationality = "";
  String _car = "";
  double _points = 0;
  int _podiums = 0;
  int _year = 0;
  String _imageUrl = "";

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
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Add Driver",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // === DRIVER NAME ===
            _buildTextField(
              label: "Driver Name",
              onChanged: (v) => _name = v!,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Driver name required!" : null,
            ),

            // === NATIONALITY ===
            _buildTextField(
              label: "Nationality",
              onChanged: (v) => _nationality = v!,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Nationality required!" : null,
            ),

            // === CAR ===
            _buildTextField(
              label: "Car",
              onChanged: (v) => _car = v!,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Car required!" : null,
            ),

            // === POINTS ===
            _buildTextField(
              label: "Points",
              number: true,
              onChanged: (v) => _points = double.tryParse(v!) ?? 0,
              validator: (v) {
                if (v == null || v.isEmpty) return "Points required!";
                if (double.tryParse(v) == null) return "Must be a number!";
                return null;
              },
            ),

            // === PODIUMS ===
            _buildTextField(
              label: "Podiums",
              number: true,
              onChanged: (v) => _podiums = int.tryParse(v!) ?? 0,
              validator: (v) {
                if (v == null || v.isEmpty) return "Podiums required!";
                if (int.tryParse(v) == null) return "Must be a number!";
                return null;
              },
            ),

            // === YEAR ===
            _buildTextField(
              label: "Year",
              number: true,
              onChanged: (v) => _year = int.tryParse(v!) ?? 0,
              validator: (v) {
                if (v == null || v.isEmpty) return "Year required!";
                if (int.tryParse(v) == null) return "Year must be a number!";
                return null;
              },
            ),

            // === IMAGE URL ===
            _buildTextField(
              label: "Image URL (optional)",
              onChanged: (v) => _imageUrl = v!,
              validator: (v) {
                if (v != null &&
                    v.isNotEmpty &&
                    Uri.tryParse(v)?.isAbsolute == false) {
                  return "Invalid image URL!";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // === SAVE BUTTON ===
            ElevatedButton(
              onPressed: _saveDriver,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent),
              child: const Text("Save",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIELD BUILDER (BIAR KODENYA RAPI AJA) (initnya utk bikin container buat masukin inputan nya)
  Widget _buildTextField({
    required String label,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  // SAVE DRIVER KE API NYA
  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "driver_name": _name,
      "nationality": _nationality,
      "car": _car,
      "points": _points,
      "podiums": _podiums,
      "year": _year,
      "image_url": _imageUrl,
    };

    final success = await api.addDriver(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Driver added successfully!")),
      );
      widget.onAdded(); // refresh tabel
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save driver")),
      );
    }
  }
}
