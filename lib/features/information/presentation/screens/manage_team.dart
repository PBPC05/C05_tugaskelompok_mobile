import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/admin_service.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/edit_team_screen.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/manage_users_screen.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_driver.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_results.dart';

class ManageTeamsScreen extends StatefulWidget {
  const ManageTeamsScreen({super.key});

  @override
  State<ManageTeamsScreen> createState() => _ManageTeamsScreenState();
}

class _ManageTeamsScreenState extends State<ManageTeamsScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _teams = [];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    final adminService = AdminService(request);
    final isAdmin = await adminService.isAdmin();
    
    if (mounted) {
      setState(() => _isAdmin = isAdmin);
      if (!isAdmin) {
        Navigator.pop(context);
      } else {
        _fetchTeams();
      }
    }
  }

  Future<void> _fetchTeams() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/teams/');
      if (response != null) {
        setState(() {
          _teams = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEditTeam(Map<String, dynamic> team) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTeamScreen(team: team)),
    );
    if (result == true) _fetchTeams();
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTeamTile(Map<String, dynamic> team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shield, color: Colors.purpleAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(team['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(team['base'] ?? 'Unknown Base', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.purpleAccent),
                  onPressed: () => _navigateToEditTeam(team),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTeamStat('Champs', team['world_championships']?.toString() ?? '0'),
                _buildTeamStat('Poles', team['pole_positions']?.toString() ?? '0'),
                _buildTeamStat('Laps', team['fastest_laps']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF15151E), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: Colors.purple.shade700),
      body: RefreshIndicator(
        onRefresh: _fetchTeams,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Teams Database', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Edit team statistics and information.', style: TextStyle(fontSize: 14, color: Colors.white70)),
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
                  _buildManagementCard('Team\nManagement', Icons.groups, Colors.purple, () {}),
                  _buildManagementCard('Race\nResults', Icons.emoji_events, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageResultsScreen()))),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Team Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Row(children: [Expanded(child: _buildStatCard('Total Teams', _teams.length.toString(), Icons.groups, Colors.purple))]),
              const SizedBox(height: 24),
              const Text('Team List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (_teams.isEmpty) const Center(child: Text("No teams found", style: TextStyle(color: Colors.grey))) else ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _teams.length, itemBuilder: (context, index) => _buildTeamTile(_teams[index])),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}