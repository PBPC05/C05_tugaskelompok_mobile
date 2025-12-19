import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/authentication/domain/services/admin_service.dart';
import 'package:provider/provider.dart';

class PitTalkSidebar extends StatefulWidget {
  final String currentRoute;
  final bool isMobile;
  final VoidCallback? onClose;

  const PitTalkSidebar({
    super.key,
    required this.currentRoute,
    this.isMobile = false,
    this.onClose,
  });

  @override
  State<PitTalkSidebar> createState() => _PitTalkSidebarState();
}

class _PitTalkSidebarState extends State<PitTalkSidebar>
    with SingleTickerProviderStateMixin {
  bool infoExpanded = false;
  bool historyExpanded = false;

  bool? _isAdmin;
  bool _adminLoading = false;
  late CookieRequest _request;

  @override
  void initState() {
    super.initState();
    _request = context.read<CookieRequest>();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    if (!_request.loggedIn) {
      setState(() {
        _isAdmin = false;
        _adminLoading = false;
      });
      return;
    }

    if (_adminLoading) return;
    
    setState(() {
      _adminLoading = true;
    });

    try {
      final adminService = AdminService(_request);
      final result = await adminService.isAdmin().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          return false;
        },
      );

      if (mounted) {
        setState(() {
          _isAdmin = result;
          _adminLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _adminLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRequest = context.watch<CookieRequest>();

    if (newRequest.loggedIn != _request.loggedIn) {
      _request = newRequest;
      _loadAdminStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _request.loggedIn;
    final sidebarWidth = 260.0;

    final showAdminDashboard = isLoggedIn && _isAdmin == true;
    final showHistoryAdminLinks = isLoggedIn && _isAdmin == true;

    final content = Material(
      color: const Color.fromARGB(255, 59, 9, 9),
      child: SizedBox(
        width: sidebarWidth,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          children: [
            GestureDetector(
              onTap: () {
                context.go("/");
                widget.onClose?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  "assets/images/pittalk-logo.png",
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
    
            _navTile(context, "News", "/news", Icons.newspaper),
            _navTile(context, "Forums", "/forums", Icons.forum),
    
            _expandable(
              title: "Information",
              expanded: infoExpanded,
              onTap: () => setState(() => infoExpanded = !infoExpanded),
              children: [
                _navChild(context, "Drivers", "/information/drivers"),
                _navChild(context, "Teams", "/information/teams"),
                _navChild(context, "Schedule", "/information/schedule"),
                _navChild(context, "Standings", "/information/standings"),
              ],
            ),
    
            _expandable(
              title: "History",
              expanded: historyExpanded,
              onTap: () => setState(() => historyExpanded = !historyExpanded),
              children: [
                if (showHistoryAdminLinks) ...[
                  _navChild(context, "Drivers History Admin", "/history/drivers/admin"),
                  _navChild(context, "GP Winners Admin", "/history/winners/admin"),
                ] else ...[
                  _navChild(context, "Drivers History", "/history/drivers"),
                  _navChild(context, "GP Winners History", "/history/winners"),
                ],
              ],
            ),
    
            _navTile(context, "Predictions", "/prediction", Icons.timeline),
            
            if (!isLoggedIn) ...[
              _navTile(context, "Login", "/login", Icons.login),
              _navTile(context, "Register", "/register", Icons.app_registration),
            ],

            if (isLoggedIn)
              _navTile(context, "User Dashboard", "/user_dashboard", Icons.dashboard),

            if (showAdminDashboard)
              _navTile(context, "Admin Dashboard", "/admin", Icons.admin_panel_settings),

            if (isLoggedIn && _isAdmin == null && _adminLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.isMobile) return content;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: content,
        ),
      ],
    );
  }

  Widget _navTile(
      BuildContext context, String title, String route, IconData icon) {
    final bool active = widget.currentRoute.startsWith(route) || 
                       (route == "/" && widget.currentRoute == "/") ||
                       (route != "/" && widget.currentRoute == route);
    return ListTile(
      leading: Icon(icon, color: active ? Colors.redAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.redAccent : Colors.white,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (widget.currentRoute != route) {
          context.go(route);
        }
        widget.onClose?.call();
      },
    );
  }

  Widget _expandable({
    required String title,
    required bool expanded,
    required Function() onTap,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: Colors.redAccent,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: expanded,
        children: children,
        onExpansionChanged: (v) => onTap(),
      ),
    );
  }

  Widget _navChild(BuildContext context, String title, String route) {
    final bool active = widget.currentRoute == route;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 40),
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.redAccent : Colors.white70,
        ),
      ),
      onTap: () {
        if (widget.currentRoute != route) {
          context.go(route);
        }
        widget.onClose?.call();
      },
    );
  }
}