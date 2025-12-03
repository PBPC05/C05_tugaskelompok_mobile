import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/authentication/data/models/user.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/authentication_page.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/login.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/manage_users_screen.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/register.dart';
import 'package:pittalk_mobile/features/forums/forums.dart';
import 'package:pittalk_mobile/features/history/presentation/screens/history_driver_admin_page.dart';
import 'package:pittalk_mobile/features/history/presentation/screens/history_driver_user_page.dart';
import 'package:pittalk_mobile/features/history/presentation/screens/history_page.dart';
import 'package:pittalk_mobile/features/news/presentation/screens/news_page.dart';
import 'package:pittalk_mobile/features/prediction/prediction.dart';
import 'package:pittalk_mobile/features/user/presentation/screens/user_page.dart';
import 'package:pittalk_mobile/mainpage/presentation/screens/main_page.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/mobile_sidebar_wrapper.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/user_dashboard.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/drivers_page.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/schedule_page.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/standings_page.dart';
import 'package:pittalk_mobile/features/information/presentation/screens/teams_page.dart';
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:pittalk_mobile/features/news/presentation/screens/edit_form.dart';
import 'package:pittalk_mobile/features/news/presentation/screens/news_form.dart';
import 'package:pittalk_mobile/features/history/presentation/screens/winner_user_page.dart';
import 'package:pittalk_mobile/features/history/presentation/screens/winner_admin_page.dart';

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
      path: '/login',
      builder: (_, __) => const PageWrapper(child: LoginPage()),
    ),

    GoRoute(
      path: '/register',
      builder: (_, __) => const PageWrapper(child: RegisterPage()),
    ),

    GoRoute(
      path: '/user_dashboard', 
      builder: (_, __) => const PageWrapper(child: UserDashboard())
    ),

    GoRoute(
      path: '/admin',
      builder: (_, __) => const PageWrapper(child: ManageUsersScreen()),
    ),

    GoRoute(
      path: '/news',
      builder: (_, __) => const PageWrapper(child: NewsPage()),
      routes: [
        GoRoute(
          path: 'create-news',
          builder: (_, __) => const NewsFormPage(),
        ),
        GoRoute(
          path: 'edit-news',
          builder: (context, state) {
            final news = state.extra as News;
            return EditFormPage(news: news,);
          },
        ),
      ]
    ),

    GoRoute(
      path: '/history',
      builder: (_, __) => const PageWrapper(child: HistoryPage()),
      routes: [
        GoRoute(
          path: 'drivers',
          builder: (_, __) => const PageWrapper(child: DriverUserPage()),
        ),
        GoRoute(
          path: 'drivers/admin',
          builder: (_, __) => const PageWrapper(child: DriverAdminPage()),
        ),

        GoRoute(
          path: 'winners',
          builder: (_, __) => const PageWrapper(child: WinnerUserPage()),
        ),
        GoRoute(
          path: 'winners/admin',
          builder: (_, __) => const PageWrapper(child: WinnerAdminPage()),
        ),
      ],
    ),

    GoRoute(
      path: '/information/drivers',
      builder: (_, __) => const PageWrapper(child: DriversEntryPage()),
    ),

    GoRoute(
      path: '/information/teams',
      builder: (_, __) => const PageWrapper(child: TeamsPage()),
    ),

    GoRoute(
      path: '/information/schedule',
      builder: (_, __) => const PageWrapper(child: SchedulePage()),
    ),

    GoRoute(
      path: '/information/standings',
      builder: (_, __) => const PageWrapper(child: StandingsPage()),
    ),

    GoRoute(
      path: '/prediction',
      builder: (_, __) => const PageWrapper(child: PredictionPage()),
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
      appBar: null,

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
