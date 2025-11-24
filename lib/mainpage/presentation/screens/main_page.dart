import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/section_header.dart';
import '../widgets/news_card.dart';
import '../widgets/forums_card.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
          title: const Text("PitTalk"),
          backgroundColor: Colors.black,
        ),
        drawer: PitTalkSidebar(
          currentRoute: GoRouterState.of(context).uri.toString(),
        ),
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 900)
              PitTalkSidebar(
                currentRoute: GoRouterState.of(context).uri.toString(),
              ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeroBanner(),
                  const SectionHeader("Featured News"),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      4,
                      (i) => const SizedBox(
                        width: 180,
                        child: NewsCard(title: "News placeholder"),
                      ),
                    ),
                  ),
                  const SectionHeader("Latest Forums"),
                  Column(
                    children: List.generate(
                      3,
                      (i) => const ForumsCard(
                        title: "Forum post placeholder",
                        author: "User123",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/header-main.jpg", fit: BoxFit.cover),
          ),
          const Positioned(
            left: 20,
            bottom: 20,
            child: Text(
              "Welcome to PitTalk",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
