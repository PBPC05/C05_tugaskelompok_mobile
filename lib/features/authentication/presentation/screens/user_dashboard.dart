import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/auth_service.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/edit_profile_screen.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/login.dart';
import 'package:go_router/go_router.dart';

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
      context.go('/login');
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
                        textAlign: TextAlign.center,
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
                      _buildWelcomeHeader(),
                      const SizedBox(height: 16),
                      _buildProfileAndStatsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE10600), Color(0xFFFF1E00)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_user!.username}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your personal dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade100,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _user!.username[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAndStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For mobile, stack vertically
        return Column(
          children: [
            _buildProfileInfo(),
            const SizedBox(height: 16),
            _buildAccountInfo(),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildRecentActivity(),
            const SizedBox(height: 16),
            _buildQuickActions(),
          ],
        );
      },
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
        children: [
          // Profile Avatar and Name
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE10600),
            child: Text(
              _user!.username[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _user!.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _user!.email?.isNotEmpty == true ? _user!.email! : 'No email set',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          // Profile Details
          if (profile?.phoneNumber != null && profile!.phoneNumber!.isNotEmpty)
            _buildInfoRowWithIcon(
              Icons.phone,
              profile.phoneNumber!,
            )
          else
            _buildInfoRowWithIcon(Icons.phone, 'No phone'),
          const SizedBox(height: 12),
          if (profile?.nationality != null && profile!.nationality!.isNotEmpty)
            _buildInfoRowWithIcon(
              Icons.flag,
              profile.nationality!,
            )
          else
            _buildInfoRowWithIcon(Icons.flag, 'Not Set'),
          const SizedBox(height: 12),
          if (profile?.address != null && profile!.address!.isNotEmpty)
            _buildInfoRowWithIcon(
              Icons.location_on,
              profile.address!,
            )
          else
            _buildInfoRowWithIcon(Icons.location_on, 'No address set'),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),
          // Bio Section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About me:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              profile?.bio?.isNotEmpty == true
                  ? profile!.bio!
                  : 'No bio yet...',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()),
                );

                if (result == true) {
                  _loadUserProfile();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo() {
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
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountRow(
            'Status:',
            _user!.isActive ? 'Active' : 'Banned',
            _user!.isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildAccountRow(
            'Member since:',
            DateFormat('MMM dd, yyyy').format(_user!.dateJoined),
            Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          _buildAccountRow(
            'Last login:',
            _user!.lastLogin != null
                ? DateFormat('MMM dd, yyyy').format(_user!.lastLogin!)
                : 'Never',
            Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        _buildStatCard(
          'Threads Created',
          _stats!.threadsCount.toString(),
          Icons.forum,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Votes Cast',
          _stats!.votesCount.toString(),
          Icons.how_to_vote,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Comments',
          _stats!.commentsCount.toString(),
          Icons.comment,
          Colors.purple,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
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
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.description,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No recent activity yet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start creating threads and voting to see your activity here!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Create Thread',
            'Start a new discussion',
            Icons.add,
            Colors.red,
            () => context.go('/forums'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Browse Threads',
            'Explore discussions',
            Icons.search,
            Colors.blue,
            () => context.go('/forums'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Edit Profile',
            'Update your information',
            Icons.edit,
            Colors.green,
            () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              );

              if (result == true) {
                _loadUserProfile();
              }
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Logout',
            'Sign out of your account',
            Icons.logout,
            Colors.grey,
            () async {
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade800, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}