import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pittalk_mobile/mainpage/data/mainpage_api.dart';

import '../widgets/sidebar.dart';
import '../widgets/mobile_sidebar_wrapper.dart';
import '../widgets/section_header.dart';
import '../widgets/news_card.dart';
import '../widgets/forums_card.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text("PitTalk"),
              backgroundColor: Colors.black,
            ),

      body: Row(
        children: [
          if (isDesktop)
            PitTalkSidebar(
              currentRoute: currentRoute,
              isMobile: false,
            ),

          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroBanner(),

                    const SizedBox(height: 32),
                    const SectionHeader("Featured News"),
                    const SizedBox(height: 12),
                    _NewsSection(),

                    const SizedBox(height: 32),
                    const SectionHeader("Latest Forums"),
                    const SizedBox(height: 12),
                    _ForumsSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return MobileSidebarWrapper(
        currentRoute: currentRoute,
        child: content,
      );
    }

    return content;
  }
}

class HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/header-main.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: const Text(
                "Welcome to PitTalk",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 6, color: Colors.black87),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService.fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No news available",
            style: TextStyle(color: Colors.grey),
          );
        }

        final newsList = snapshot.data!;
        final isDesktop = MediaQuery.of(context).size.width >= 900;

        return isDesktop
            ? Wrap(
                spacing: 16,
                runSpacing: 16,
                children: newsList.map((news) {
                  return SizedBox(
                    width: 220,
                    child: NewsCard(title: news.title),
                  );
                }).toList(),
              )
            : Column(
                children: newsList.map((news) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NewsCard(title: news.title),
                  );
                }).toList(),
              );
      },
    );
  }
}

class _ForumsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService.fetchForums(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No forums available",
            style: TextStyle(color: Colors.grey),
          );
        }

        final forums = snapshot.data!;

        return Column(
          children: forums.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ForumsCard(
                title: f.title,
                author: f.author,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
