import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EditTeamScreen extends StatefulWidget {
  final Map<String, dynamic> team;

  const EditTeamScreen({super.key, required this.team});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _champsController;
  late TextEditingController _highestRaceController;
  late TextEditingController _polesController;
  late TextEditingController _fastestLapsController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _champsController = TextEditingController(text: widget.team['world_championships']?.toString() ?? '0');
    _highestRaceController = TextEditingController(text: widget.team['highest_race_finish']?.toString() ?? '');
    _polesController = TextEditingController(text: widget.team['pole_positions']?.toString() ?? '0');
    _fastestLapsController = TextEditingController(text: widget.team['fastest_laps']?.toString() ?? '0');
  }

  @override
  void dispose() {
    _champsController.dispose();
    _highestRaceController.dispose();
    _polesController.dispose();
    _fastestLapsController.dispose();
    super.dispose();
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    dynamic rawId = widget.team['pk'] ?? widget.team['id'];
    int? teamId;
    if (rawId != null) {
      teamId = int.tryParse(rawId.toString());
    }

    if (teamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Team ID not found.'), backgroundColor: Colors.red),
      );
      setState(() => _isSaving = false);
      return;
    }

    final request = context.read<CookieRequest>();
    final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/admin/teams/flutter/$teamId/update/';

    try {
      final response = await request.post(url, {
        'world_championships': _champsController.text,
        'highest_race_finish': _highestRaceController.text,
        'pole_positions': _polesController.text,
        'fastest_laps': _fastestLapsController.text,
      });

      if (response['ok'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Team updated successfully!'), backgroundColor: Colors.green),
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
            msg = "Server Error: Received HTML. Check Login Session.";
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

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.purpleAccent)),
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
        title: Text('Edit ${widget.team['name']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade700,
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups, color: Colors.purpleAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.team['full_name'] ?? widget.team['name'] ?? 'Unknown',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            widget.team['base'] ?? 'N/A',
                            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text("Statistics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildTextField('World Championships', _champsController, isNumber: true),
              _buildTextField('Pole Positions', _polesController, isNumber: true),
              _buildTextField('Fastest Laps', _fastestLapsController, isNumber: true),
              _buildTextField('Highest Race Finish', _highestRaceController),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
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