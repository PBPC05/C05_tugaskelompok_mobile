import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:pittalk_mobile/features/news/presentation/screens/news_detail.dart';
import 'package:pittalk_mobile/features/news/presentation/widgets/news_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/mainpage/presentation/widgets/sidebar.dart';
import 'package:go_router/go_router.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<News> listNews = [];
  late Future<List<News>> futureNews;
  String chosenCategory = "all";

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    futureNews = fetchNews(request);
  }

  Future<List<News>> fetchNews(CookieRequest request) async {
    // Clear news list
    listNews.clear();

    final response = await request.get('https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/news/json/');

    // Decode response to json format
    var data = response;

    // Convert json data to NewsEntry objects
    for (var d in data) {
      if (d != null) {
        listNews.add(News.fromJson(d));
      }
    }
    return listNews.reversed.toList();
  }

  Future<void> refreshNews() async {
    final request = context.read<CookieRequest>();
    final newsList = await fetchNews(request);
    setState(() {
      listNews = newsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    final categoryMap = {
      "All Categories": "all",
      "Formula 1/FIA": "f1",
      "Championship": "championship",
      "Team": "team",
      "Driver": "driver",
      "Constructor": "constructor",
      "Race": "race",
      "Analysis": "analysis",
      "F1 History": "history",
      "F1 Fanbase": "fanbase",
      "Exclusive": "exclusive",
      "Other": "other",
    };

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(title: const Text("PitTalk News")),
      drawer: PitTalkSidebar(
        currentRoute: GoRouterState.of(context).uri.toString(),
      ),
      body: Column(
        children: [
          // Dropdown button for filtering
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton(
              value: chosenCategory,
              hint: const Text("Filter by category..."),
              items: categoryMap.keys
                  .map(
                    (c) =>
                        DropdownMenuItem(value: categoryMap[c], child: Text(c)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  chosenCategory = value!;
                });
                refreshNews();
              },
            ),
          ),

          // Show news
          Expanded(
            child: FutureBuilder(
              future: futureNews,
              builder: (context, AsyncSnapshot snapshot) {
                List<News> shownNews = [];

                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    shownNews = snapshot.data;
                    if (chosenCategory != "all") {
                      shownNews = shownNews
                          .where((item) => item.category == chosenCategory)
                          .toList();
                    }
                  }

                  if (snapshot.hasData && shownNews.isNotEmpty) {
                    return ListView.builder(
                      itemCount: shownNews.length,
                      itemBuilder: (_, index) => NewsCard(
                        news: shownNews[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailPage(news: shownNews[index]),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'No news found',
                            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "It looks like there are no recent articles in this category.",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
