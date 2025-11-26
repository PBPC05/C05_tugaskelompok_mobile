import 'package:go_router/go_router.dart';
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
    ),

    GoRoute(
      path: '/information',
      builder: (_, __) => const InformationPage(),
    ),

    GoRoute(
      path: '/prediction',
      builder: (_, __) => const PredictionPage(),
    ),

    GoRoute(
      path: '/user',
      builder: (_, __) => const UserPage(),
    ),

    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),

    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),
    
  ],
);
