import 'package:flutter/material.dart';
import 'sidebar.dart';

class MobileSidebarWrapper extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MobileSidebarWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MobileSidebarWrapper> createState() => _MobileSidebarWrapperState();
}

class _MobileSidebarWrapperState extends State<MobileSidebarWrapper> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        if (open)
          PitTalkSidebar(
            currentRoute: widget.currentRoute,
            isMobile: true,
            onClose: () => setState(() => open = false),
          ),

        Positioned(
          bottom: 20,
          left: 20,
          child: AnimatedScale(
            scale: open ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton(
              heroTag: "sidebar-fab",
              backgroundColor: const Color.fromARGB(255, 255, 148, 148),
              onPressed: () => setState(() => open = !open),
              child: Icon(
                open ? Icons.close : Icons.menu,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
