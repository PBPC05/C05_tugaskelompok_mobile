import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/auth_service.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/edit_profile_screen.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/login.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  User? _user;
  UserStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    final result = await authService.getUserProfile();

    setState(() {
      _isLoading = false;
      if (result['status'] == true) {
        _user = result['user'];
        _stats = result['stats'];
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  Future<void> _handleLogout() async {
    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    final success = await authService.logout();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: const Color(0xFFE10600),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildProfileInfo(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE10600), Color(0xFFFF1E00)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _user!.username[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_user!.email != null && _user!.email!.isNotEmpty)
                  Text(
                    _user!.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${DateFormat('MMM dd, yyyy').format(_user!.dateJoined)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Threads',
            _stats!.threadsCount.toString(),
            Icons.forum,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Votes',
            _stats!.votesCount.toString(),
            Icons.how_to_vote,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Comments',
            _stats!.commentsCount.toString(),
            Icons.comment,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final profile = _user!.profile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (profile?.phoneNumber != null && profile!.phoneNumber!.isNotEmpty)
            _buildInfoRow(Icons.phone, 'Phone', profile.phoneNumber!),
          if (profile?.nationality != null && profile!.nationality!.isNotEmpty)
            _buildInfoRow(Icons.flag, 'Nationality', profile.nationality!),
          if (profile?.address != null && profile!.address!.isNotEmpty)
            _buildInfoRow(Icons.location_on, 'Address', profile.address!),
          if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
            const Divider(color: Colors.grey, height: 32),
            const Text(
              'Bio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
          if (profile == null ||
              (profile.phoneNumber?.isEmpty ?? true) &&
                  (profile.nationality?.isEmpty ?? true) &&
                  (profile.address?.isEmpty ?? true) &&
                  (profile.bio?.isEmpty ?? true))
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No profile information yet. Edit your profile to add details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton('Edit Profile', Icons.edit, Colors.green, () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );

          if (result == true) {
            _loadUserProfile();
          }
        }),
        const SizedBox(height: 8),
        _buildActionButton('Logout', Icons.logout, Colors.grey, () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            _handleLogout();
          }
        }),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
