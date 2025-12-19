import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/forums/forum_state_manager.dart';
import 'package:pittalk_mobile/shared/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CookieRequest()),
        ChangeNotifierProvider(create: (_) => ForumStateManager()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        title: "PitTalk",
        routerConfig: router,
      ),
    );
  }
}

