import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/authentication_page.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/login.dart';
import 'package:pittalk_mobile/features/authentication/presentation/screens/register.dart';
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
      builder: (_, __) => const ForumsPage(),
    ),

    GoRoute(
      path: '/authentication',
      builder: (_, __) => const AuthenticationPage(),
    ),

    GoRoute(
      path: '/news',
      builder: (_, __) => const NewsPage(),
    ),

    GoRoute(
      path: '/admins',
      builder: (_, __) => const AdminsPage(),
    ),

    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryPage(),
      routes: [
        GoRoute(
          path: 'drivers',
          builder: (_, __) => const HistoryDriverUserPage(),
        ),
        GoRoute(
          path: 'drivers/admin',
          builder: (_, __) => const HistoryDriverAdminPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/information/drivers',
      builder: (_, __) => const DriversPage(),
    ),

    GoRoute(
      path: '/information/teams',
      builder: (_, __) => const TeamsPage(),
    ),

    GoRoute(
      path: '/information/schedule',
      builder: (_, __) => const SchedulePage(),
    ),

    GoRoute(
      path: '/information/standings',
      builder: (_, __) => const StandingsPage(),
    ),

    GoRoute(
      path: '/prediction',
      builder: (_, __) => const PredictionPage(),
    ),

    GoRoute(
      path: '/user',
      builder: (_, __) => const UserPage(),
    ),
  ],
);
