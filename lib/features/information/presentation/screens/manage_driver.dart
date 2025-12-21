import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/admin_service.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/manage_users_screen.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/edit_driver_screen.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_team.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/manage_results.dart';

class ManageDriversScreen extends StatefulWidget {
  const ManageDriversScreen({super.key});

  @override
  State<ManageDriversScreen> createState() => _ManageDriversScreenState();
}

class _ManageDriversScreenState extends State<ManageDriversScreen> {
  bool _isLoading = true;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _drivers = [];

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
      setState(() {
        _isAdmin = isAdmin;
      });

      if (!isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Admin privileges required.'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      } else {
        _fetchDrivers();
      }
    }
  }

  Future<void> _fetchDrivers() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/information/api/drivers/');
      if (response != null) {
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load drivers: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEditDriver(Map<String, dynamic> driver) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDriverScreen(driver: driver)),
    );
    if (result == true) _fetchDrivers();
  }


  Widget _buildManagementCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white.withOpacity(0.9)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
              ),
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
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDriverTile(Map<String, dynamic> driver) {
    final teamName = driver['team'] is String ? driver['team'] : (driver['team']?['name'] ?? 'N/A');
    
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
                CircleAvatar(
                  backgroundColor: const Color(0xFFE10600),
                  child: Text(
                    driver['number']?.toString() ?? '#',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['full_name'] ?? 'Unknown',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        teamName,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _navigateToEditDriver(driver),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDriverStat('Points', driver['points']?.toString() ?? '0'),
                _buildDriverStat('Podiums', driver['podiums']?.toString() ?? '0'),
                _buildDriverStat('Champs', driver['world_championships']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF15151E),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE10600))),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        backgroundColor: Color(0xFF15151E),
        body: Center(child: Text('Access Denied', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDrivers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drivers Database', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Edit driver statistics and information.', style: TextStyle(fontSize: 14, color: Colors.white70)),
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
                  _buildManagementCard('User\nManagement', Icons.people, Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageUsersScreen()));
                  }),
                  _buildManagementCard('Driver\nManagement', Icons.directions_car, Colors.green, () {}),
                  _buildManagementCard('Team\nManagement', Icons.groups, Colors.purple, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageTeamsScreen()));
                  }),
                  _buildManagementCard('Race\nResults', Icons.emoji_events, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageResultsScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Driver Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Drivers', _drivers.length.toString(), Icons.people_alt, Colors.green)),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Driver List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (_drivers.isEmpty)
                const Center(child: Text("No drivers found", style: TextStyle(color: Colors.grey)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _drivers.length,
                  itemBuilder: (context, index) {
                    return _buildDriverTile(_drivers[index]);
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}