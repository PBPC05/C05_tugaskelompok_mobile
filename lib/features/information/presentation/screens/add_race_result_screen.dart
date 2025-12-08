import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddRaceResultScreen extends StatefulWidget {
  const AddRaceResultScreen({super.key});

  @override
  State<AddRaceResultScreen> createState() => _AddRaceResultScreenState();
}

class _AddRaceResultScreenState extends State<AddRaceResultScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingOptions = true;

  List<dynamic> _races = [];
  List<dynamic> _drivers = [];
  List<dynamic> _teams = [];

  String? _selectedRaceId;
  String? _selectedDriverId;
  String? _selectedTeamId;
  
  final TextEditingController _finishPosController = TextEditingController();
  final TextEditingController _gridPosController = TextEditingController();
  final TextEditingController _lapsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  
  String _status = 'FINISHED'; 
  bool _fastestLap = false;

  final List<String> _statusOptions = ['FINISHED', 'DNF', 'DNS', 'DSQ', 'NC'];

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    final request = context.read<CookieRequest>();
    try {
      final responses = await Future.wait([
        request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/schedule/2025/'), 
        request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/drivers/'),
        request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/teams/'),
      ]);

      if (mounted) {
        setState(() {
          _races = responses[0]['data'] ?? [];
          _drivers = responses[1] is List ? responses[1] : [];
          _teams = responses[2] is List ? responses[2] : [];
          _isFetchingOptions = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching options: $e");
      if (mounted) setState(() => _isFetchingOptions = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRaceId == null || _selectedDriverId == null || _selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Race, Driver, and Team")));
      return;
    }

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/raceresult/append/flutter/';

    try {
      final response = await request.post(url, {
        'race': _selectedRaceId,
        'driver': _selectedDriverId,
        'team': _selectedTeamId,
        'finish_position': _finishPosController.text.isEmpty ? null : _finishPosController.text,
        'grid_position': _gridPosController.text,
        'laps': _lapsController.text,
        'time_text': _timeController.text,
        'points_awarded': _pointsController.text,
        'status': _status,
        'fastest_lap': _fastestLap ? 'true' : 'false',
      });

      if (response['ok'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Result added successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        String msg = response['message'] ?? 'Failed to add result';
        if (response['errors'] != null) msg += "\n${response['errors']}";
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
         String msg = "Error: $e";
         if (e.toString().contains("<")) msg = "Server Error (HTML). Check login.";
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown(String label, List<dynamic> items, String? value, Function(String?) onChanged, {String keyName = 'name'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: const Color(0xFF1E1E2C),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFF1E1E2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: items.map((item) {
            final id = item['pk']?.toString() ?? item['id']?.toString() ?? '';
            final name = item[keyName] ?? item['full_name'] ?? 'Unknown';
            
            if (id.isEmpty) return null;

            return DropdownMenuItem(value: id, child: Text(name, overflow: TextOverflow.ellipsis));
          }).whereType<DropdownMenuItem<String>>().toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFF1E1E2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingOptions) {
      return const Scaffold(backgroundColor: Color(0xFF15151E), body: Center(child: CircularProgressIndicator(color: Colors.orange)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(
        title: Text('Add Race Result', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDropdown("Race (Requires 'pk' in API)", _races, _selectedRaceId, (val) => setState(() => _selectedRaceId = val), keyName: 'name'),
              _buildDropdown("Driver", _drivers, _selectedDriverId, (val) => setState(() => _selectedDriverId = val), keyName: 'full_name'),
              _buildDropdown("Team", _teams, _selectedTeamId, (val) => setState(() => _selectedTeamId = val), keyName: 'name'),
              
              Row(children: [
                Expanded(child: _buildTextField("Finish Pos", _finishPosController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Grid Pos", _gridPosController, isNumber: true)),
              ]),
              
              Row(children: [
                Expanded(child: _buildTextField("Laps", _lapsController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Points", _pointsController, isNumber: true)),
              ]),

              _buildTextField("Time / Gap (Text)", _timeController),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFF1E1E2C), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              SwitchListTile(
                title: const Text("Fastest Lap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                value: _fastestLap,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => _fastestLap = val),
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}