import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_detail.dart';
import 'package:pittalk_mobile/features/news/presentation/screens/news_detail.dart';
import 'package:pittalk_mobile/mainpage/data/mainpage_api.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: const Color(0xFF0F1115),
      body: Row(
        children: [
          if (isDesktop)
            PitTalkSidebar(
              currentRoute: currentRoute,
              isMobile: false,
            ),

          Expanded(
            child: Container(
              color: const Color(0xFF0F1115),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    HeroBanner(),

                    SizedBox(height: 40),
                    SectionHeader("Featured News"),
                    SizedBox(height: 16),
                    _NewsSection(),

                    SizedBox(height: 40),
                    SectionHeader("Latest Forums"),
                    SizedBox(height: 16),
                    _ForumsSection(),
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
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/header-main.jpg",
                fit: BoxFit.cover,
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Welcome to PitTalk",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NewsSection extends StatelessWidget {
  const _NewsSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiMainPage.fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No news available",
            style: TextStyle(color: Colors.grey),
          );
        }

        final featured = snapshot.data!
            .where((n) => n.isFeatured)
            .toList();

        if (featured.isEmpty) return const SizedBox();

        final mainNews = featured.first;
        final rest = featured.skip(1).take(4).toList();

        return Column(
          children: [
            FeaturedNewsCard(
              title: mainNews.title,
              imageUrl: mainNews.thumbnail,
              date: mainNews.createdAt.toString(),
              views: mainNews.newsViews,
              onTap: () {
                final request = Provider.of<CookieRequest>(context, listen: false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewsDetailPage(news: mainNews, userLoggedIn: request.loggedIn),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                return isDesktop
                    ? Row(
                        children: rest.take(2).map((news) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: NewsCard(
                                title: news.title,
                                imageUrl: news.thumbnail,
                                date: news.createdAt.toString(),
                                views: news.newsViews,
                                onTap: () {
                                final request = Provider.of<CookieRequest>(context, listen: false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsDetailPage(news: news, userLoggedIn: request.loggedIn),
                                  ),
                                );
                              },
                              ),
                              
                            ),
                          );
                        }).toList(),
                      )
                    : Column(
                        children: rest.map((news) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: NewsCard(
                              title: news.title,
                              imageUrl: news.thumbnail,
                              date: news.createdAt.toString(),
                              views: news.newsViews,
                              onTap: () {
                                final request = Provider.of<CookieRequest>(context, listen: false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsDetailPage(news: news, userLoggedIn: request.loggedIn),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
              },
            ),
          ],
        );
      },
    );
  }
}



class _ForumsSection extends StatelessWidget {
  const _ForumsSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiMainPage.fetchForums(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No forums available",
            style: TextStyle(color: Colors.grey),
          );
        }

        final forums = snapshot.data!.take(6);

        return Column(
          children: forums.map((f) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ForumsCard(
                title: f.title,
                author: f.username ?? 'Anonymous',
                content: f.content,
                date: f.createdAt.toString(),
                replies: f.repliesCount,
                onTap: () {
                  final request = Provider.of<CookieRequest>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ForumDetailPage(forumId: f.id, request: request),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

