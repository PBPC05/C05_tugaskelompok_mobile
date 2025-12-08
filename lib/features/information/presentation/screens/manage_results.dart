import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/admin_service.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/add_race_result_screen.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/manage_users_screen.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_driver.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_team.dart';

class ManageResultsScreen extends StatefulWidget {
  const ManageResultsScreen({super.key});

  @override
  State<ManageResultsScreen> createState() => _ManageResultsScreenState();
}

class _ManageResultsScreenState extends State<ManageResultsScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  List<dynamic> _racesData = []; 

  @override
  void initState() {
    super.initState();
    _checkAdminAndFetch();
  }

  Future<void> _checkAdminAndFetch() async {
    final request = context.read<CookieRequest>();
    final adminService = AdminService(request);
    final isAdmin = await adminService.isAdmin();
    
    if (mounted) {
      if (!isAdmin) {
        setState(() { _isAdmin = false; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied"), backgroundColor: Colors.red));
        Navigator.pop(context);
      } else {
        setState(() => _isAdmin = true);
        _fetchResults();
      }
    }
  }

  Future<void> _fetchResults() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/manage/results/');
      if (response != null) {
        setState(() {
          _racesData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteResult(int resultId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text("Delete Result?", style: TextStyle(color: Colors.white)),
        content: const Text("This cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    final request = context.read<CookieRequest>();
    final url = 'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/raceresult/$resultId/delete/flutter/';

    try {
      final response = await request.post(url, {});
      if (response['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully"), backgroundColor: Colors.green));
        _fetchResults();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Widget _buildManagementCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaceCard(Map<String, dynamic> race) {
    List<dynamic> results = race['results'] ?? [];

    return Card(
      color: const Color(0xFF1E1E2C),
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(race['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${race['circuit']} - Round ${race['round']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Text(race['date'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          if (results.isEmpty)
             const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No results yet.", style: TextStyle(color: Colors.grey))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (ctx, i) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (ctx, i) {
                final r = results[i];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 14,
                    child: Text("${r['position']}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(r['driver_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${r['team_name']} • ${r['points']} pts", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteResult(r['pk']),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF15151E), body: Center(child: CircularProgressIndicator(color: Colors.orange)));

    if (!_isAdmin) return const Scaffold(backgroundColor: Color(0xFF15151E), body: Center(child: Text("Access Denied", style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.orange.shade800),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
            final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddRaceResultScreen()));
            if(res == true) _fetchResults();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _fetchResults,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFF7043)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Race Results', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Append or delete driver results for each race.', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
               ),
               const SizedBox(height: 24),

               const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildManagementCard('User\nManagement', Icons.people, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageUsersScreen()))),
                  _buildManagementCard('Driver\nManagement', Icons.directions_car, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageDriversScreen()))),
                  _buildManagementCard('Team\nManagement', Icons.groups, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageTeamsScreen()))),
                  _buildManagementCard('Race\nResults', Icons.emoji_events, Colors.orange, () {}),
                ],
              ),
               
               const SizedBox(height: 24),
               const Text('Existing Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
               const SizedBox(height: 16),
               
               if (_racesData.isEmpty)
                 const Center(child: Text("No races found.", style: TextStyle(color: Colors.white)))
               else
                 ..._racesData.map((race) => _buildRaceCard(race)).toList(),
               
               const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}