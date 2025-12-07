import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditDriverScreen extends StatefulWidget {
  final Map<String, dynamic> driver;

  const EditDriverScreen({super.key, required this.driver});

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _podiumsController;
  late TextEditingController _pointsController;
  late TextEditingController _entriesController;
  late TextEditingController _champsController;
  late TextEditingController _highestRaceController;
  late TextEditingController _highestGridController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _podiumsController = TextEditingController(text: widget.driver['podiums']?.toString() ?? '0');
    _pointsController = TextEditingController(text: widget.driver['points']?.toString() ?? '0.0');
    _entriesController = TextEditingController(text: widget.driver['grands_prix_entered']?.toString() ?? '0');
    _champsController = TextEditingController(text: widget.driver['world_championships']?.toString() ?? '0');
    _highestRaceController = TextEditingController(text: widget.driver['highest_race_finish']?.toString() ?? '');
    _highestGridController = TextEditingController(text: widget.driver['highest_grid_position']?.toString() ?? '');
  }

  @override
  void dispose() {
    _podiumsController.dispose();
    _pointsController.dispose();
    _entriesController.dispose();
    _champsController.dispose();
    _highestRaceController.dispose();
    _highestGridController.dispose();
    super.dispose();
  }

  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    dynamic rawId = widget.driver['pk'] ?? widget.driver['id'];
    int? driverId;
    if (rawId != null) {
      driverId = int.tryParse(rawId.toString());
    }

    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Driver ID not found.'), backgroundColor: Colors.red),
      );
      setState(() => _isSaving = false);
      return;
    }

    final request = context.read<CookieRequest>();
    final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/admin/drivers/flutter/$driverId/update/';

    try {
      final response = await request.post(url, {
        'podiums': _podiumsController.text,
        'points': _pointsController.text,
        'grands_prix_entered': _entriesController.text,
        'world_championships': _champsController.text,
        'highest_race_finish': _highestRaceController.text,
        'highest_grid_position': _highestGridController.text,
      });

      if (response['ok'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        String errorMessage = 'Update failed';
        if (response['errors'] != null) {
            errorMessage = response['errors'].toString();
        } else if (response['message'] != null) {
            errorMessage = response['message'];
        }
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
            );
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = "Error: $e";
        if (e.toString().contains("SyntaxError") || e.toString().contains("<")) {
            msg = "Server Error: Received HTML instead of JSON. Check your Login Session.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool isDecimal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber 
              ? TextInputType.numberWithOptions(decimal: isDecimal) 
              : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE10600))),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Field cannot be empty';
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(
        title: Text('Edit ${widget.driver['full_name']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE10600),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF252537),
                      child: Text(
                        widget.driver['number']?.toString() ?? '#',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.driver['full_name'] ?? 'Unknown',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          widget.driver['team'] is String ? widget.driver['team'] : (widget.driver['team']?['name'] ?? 'N/A'),
                          style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text("Statistics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildTextField('Podiums', _podiumsController, isNumber: true),
              _buildTextField('Points', _pointsController, isNumber: true, isDecimal: true),
              _buildTextField('Grand Prix Entries', _entriesController, isNumber: true),
              _buildTextField('World Championships', _champsController, isNumber: true),
              _buildTextField('Highest Race Finish', _highestRaceController),
              _buildTextField('Highest Grid Position', _highestGridController),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE10600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}