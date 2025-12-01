import 'package:flutter/material.dart';
import '../../data/models/winner_model.dart';
import '../../data/history_api.dart';

class WinnerEditModal extends StatefulWidget {
  final Winner winner;
  final HistoryApi api;
  final VoidCallback onUpdated;

  const WinnerEditModal({super.key, required this.winner, required this.api, required this.onUpdated});

  @override
  State<WinnerEditModal> createState() => _WinnerEditModalState();
}

class _WinnerEditModalState extends State<WinnerEditModal> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> input;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    // isi awal form dengan data winner
    input = {
      "winner": widget.winner.winnerName,
      "car": widget.winner.car,
      "grand_prix": widget.winner.grandPrix,
      "laps": widget.winner.laps,
      "time": widget.winner.time,
      "date": widget.winner.date,
      "image_url": widget.winner.imageUrl,
    };
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => saving = true);
    final ok = await widget.api.editWinner(widget.winner.id, input);
    setState(() => saving = false);
    if (ok) {
      widget.onUpdated();
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: const Text("Edit Winner", style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildField("Winner Name", initial: input["winner"], onSaved: (v) => input["winner"] = v),
              const SizedBox(height: 8),
              buildField("Car", initial: input["car"], onSaved: (v) => input["car"] = v),
              const SizedBox(height: 8),
              buildField("Grand Prix", initial: input["grand_prix"], onSaved: (v) => input["grand_prix"] = v),
              const SizedBox(height: 8),
              buildField("Laps", initial: input["laps"]?.toString(), keyboardType: TextInputType.number, onSaved: (v) => input["laps"] = v != null && v.isNotEmpty ? double.tryParse(v) : null),
              const SizedBox(height: 8),
              buildField("Time", initial: input["time"], onSaved: (v) => input["time"] = v),
              const SizedBox(height: 8),
              buildField("Date (YYYY-MM-DD)", initial: input["date"], onSaved: (v) => input["date"] = v),
              const SizedBox(height: 8),
              buildField("Image URL", initial: input["image_url"], onSaved: (v) => input["image_url"] = v),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.white))),
        ElevatedButton(onPressed: saving ? null : submit, child: saving ? const CircularProgressIndicator() : const Text("Simpan")),
      ],
    );
  }

  Widget buildField(String label, {String? initial, TextInputType keyboardType = TextInputType.text, required void Function(String?) onSaved}) {
    return TextFormField(
      initialValue: initial,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: Colors.grey.shade800),
      onSaved: onSaved,
      validator: (v) {
        if ((label == "Winner Name" || label == "Car" || label == "Grand Prix" || label == "Time") && (v == null || v.isEmpty)) {
          return "$label wajib diisi";
        }
        if (label.startsWith("Date") && (v == null || v.isEmpty)) return "Date wajib diisi";
        return null;
      },
    );
  }
}
