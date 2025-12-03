import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/login.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/register.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'features/forums/forums.dart';
import 'features/authentication/authentication.dart';
import 'features/news/news.dart';
import 'features/admins/admins.dart';
import 'features/history/history.dart';
import 'features/information/information.dart';
import 'features/prediction/prediction.dart';
import 'features/user/user.dart';
import 'mainpage/mainpage.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const MainPage(),
    ),

    GoRoute(
      path: '/forums',
      builder: (_, __) => const PageWrapper(child: ForumsPage()),
    ),

    GoRoute(
      path: '/authentication',
      builder: (_, __) => const PageWrapper(child: AuthenticationPage()),
    ),

    GoRoute(
      path: '/news',
      builder: (_, __) => const PageWrapper(child: NewsPage()),
    ),

    GoRoute(
      path: '/admins',
      builder: (_, __) => const PageWrapper(child: AdminsPage()),
    ),

    GoRoute(
      path: '/history',
      builder: (_, __) => const PageWrapper(child: HistoryPage()),
    ),

    GoRoute(
      path: '/information',
      builder: (_, __) => const PageWrapper(child: InformationPage()),
    ),

    GoRoute(
      path: '/prediction',
      builder: (_, __) => const PageWrapper(child: PredictionPage()),
    ),

    GoRoute(
      path: '/user',
      builder: (_, __) => const PageWrapper(child: UserPage()),
    ),

    GoRoute(
      path: '/login',
      builder: (_, __) => const PageWrapper(child: LoginPage()),
    ),

    GoRoute(
      path: '/register',
      builder: (_, __) => const PageWrapper(child: RegisterPage()),
    ),
    
  ],
);

class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final currentRoute = GoRouterState.of(context).uri.toString();

    final content = Scaffold(
      appBar: isDesktop ? null : AppBar(backgroundColor: Colors.black),
      body: Row(
        children: [
          if (isDesktop)
            PitTalkSidebar(
              currentRoute: currentRoute,
              isMobile: false,
            ),
          Expanded(child: child),
        ],
      ),
    );

    return isDesktop
        ? content
        : MobileSidebarWrapper(
            currentRoute: currentRoute,
            child: content,
          );
  }
}
