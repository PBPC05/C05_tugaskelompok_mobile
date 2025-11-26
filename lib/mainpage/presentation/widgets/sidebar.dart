import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = 260.0;

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
              child: Image.asset(
                "assets/images/pittalk-logo.png",
                height: 60,
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
                _navChild(context, "Drivers History", "/history/drivers"),
                _navChild(context, "GP History", "/history/gp"),
              ],
            ),
    
            _navTile(context, "Predictions", "/prediction", Icons.timeline),
            _navTile(context, "Admins", "/admins", Icons.admin_panel_settings),
            _navTile(context, "User", "/user", Icons.person),
            _navTile(context, "Login", "/login", Icons.login),
            _navTile(context, "Register", "/register", Icons.app_registration),
          ],
        ),
      ),
    );


    if (!widget.isMobile) return content;

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black54,
          ),
        ),

        AnimatedSlide(
          offset: Offset(0, 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: content,
        ),
      ],
    );
  }

  Widget _navTile(
      BuildContext context, String title, String route, IconData icon) {
    final bool active = widget.currentRoute == route;
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
        context.go(route);
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
        context.go(route);
        widget.onClose?.call();
      },
    );
  }
}
