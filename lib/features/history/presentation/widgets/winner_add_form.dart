import 'package:flutter/material.dart';
import '../../data/history_api.dart';

class WinnerAddForm extends StatefulWidget {
  final VoidCallback onAdded;
  final HistoryApi api;

  const WinnerAddForm({
    super.key,
    required this.onAdded,
    required this.api,
  });

  @override
  State<WinnerAddForm> createState() => _WinnerAddFormState();
}

class _WinnerAddFormState extends State<WinnerAddForm> {
  final _formKey = GlobalKey<FormState>();

  // === Variabel Input ===
  String _winner = "";
  String _car = "";
  String _grandPrix = "";
  double? _laps;
  String _time = "";
  String _date = "";
  String _imageUrl = "";

  bool saving = false;

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
            const Text("Add Winner",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),

            // === WINNER NAME ===
            _buildTextField(
              label: "Winner Name",
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Winner name required!" : null,
              onChanged: (v) => _winner = v!,
            ),

            // === CAR ===
            _buildTextField(
              label: "Car",
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Car required!" : null,
              onChanged: (v) => _car = v!,
            ),

            // === GRAND PRIX ===
            _buildTextField(
              label: "Grand Prix",
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Grand Prix required!" : null,
              onChanged: (v) => _grandPrix = v!,
            ),

// === LAPS ===
_buildTextField(
  label: "Laps",
  number: true,
  validator: (v) {
    if (v == null || v.isEmpty) return "Laps required!";
    if (double.tryParse(v) == null) return "Laps must be a number!";
    return null;
  },
  onChanged: (v) => _laps = double.tryParse(v!),
),

            // === TIME ===
            _buildTextField(
              label: "Time (e.g. 1:25:13.456)",
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Time required!" : null,
              onChanged: (v) => _time = v!,
            ),

            // === DATE ===
            _buildTextField(
              label: "Date (YYYY-MM-DD)",
              validator: (v) {
                if (v == null || v.isEmpty) return "Date required!";
                try {
                  DateTime.parse(v);
                } catch (e) {
                  return "Use format YYYY-MM-DD!";
                }
                return null;
              },
              onChanged: (v) => _date = v!,
            ),

            // === IMAGE URL (OPTIONAL) ===
            _buildTextField(
              label: "Image URL (optional)",
              validator: (v) {
                if (v != null &&
                    v.isNotEmpty &&
                    Uri.tryParse(v)?.isAbsolute == false) {
                  return "Invalid image URL!";
                }
                return null;
              },
              onChanged: (v) => _imageUrl = v!,
            ),

            const SizedBox(height: 12),

            // === BUTTON SAVE ===
            ElevatedButton(
              onPressed: saving ? null : _saveWinner,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700),
              child: saving
                  ? const CircularProgressIndicator()
                  : const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BUILDER FORM FIELD AGAR RAPI
  // ======================================================
  Widget _buildTextField({
    required String label,
    required String? Function(String?) validator,
    required Function(String?) onChanged,
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

  // ======================================================
  // SIMPAN KE API
  // ======================================================
  Future<void> _saveWinner() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "winner": _winner,
      "car": _car,
      "grand_prix": _grandPrix,
      "laps": _laps,
      "time": _time,
      "date": _date,
      "image_url": _imageUrl,
    };

    setState(() => saving = true);

    final ok = await widget.api.addWinner(data);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Winner added successfully!")),
      );
      widget.onAdded(); // refresh list
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save winner")),
      );
    }

    setState(() => saving = false);
  }
}
