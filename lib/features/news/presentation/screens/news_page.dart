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
  late Future<List<News>> futureNews = Future.value([]);
  String chosenCategory = "all";
  bool userLoggedIn = false;
  bool userIsAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      setState(() {
        futureNews = fetchNews(request);
      });
    });
  }

  // Check if user is authenticated (and if user is admin)
  void checkUserLogin() async {
    final request = context.read<CookieRequest>();
    try {
      final request1 = await request.get(
        "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/check_user",
      );
      var login = request1['is_logged_in'];
      var admin = false;

      if (login) {
        final request2 = await request.get(
          "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/prediction/check_admin",
        );
        if (request2['is_admin']) {
          admin = true;
        }
      }

      setState(() {
        userLoggedIn = login;
        userIsAdmin = admin;
      });
    } on Exception {
      setState(() {
        userLoggedIn = false;
        userIsAdmin = false;
      });
    }
  }

  Future<List<News>> fetchNews(CookieRequest request) async {
    // Clear news list
    listNews.clear();

    final response = await request.get(
      'https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id/news/json/',
    );
    debugPrint("");

    // Decode response to json format
    var data = response;

    // Convert json data to NewsEntry objects
    for (var d in data) {
      if (d != null) {
        listNews.add(News.fromJson(d));
      }
    }
    return listNews.toList();
  }

  Future<void> refreshNews() async {
    final request = context.read<CookieRequest>();
    setState(() {
      futureNews = fetchNews(request);
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Dropdown button for filtering
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Filter by category..."),
                const SizedBox(width: 8.0),
                DropdownButton(
                  value: chosenCategory,
                  hint: const Text("Filter by category..."),
                  items: categoryMap.keys
                      .map(
                        (c) => DropdownMenuItem(
                          value: categoryMap[c],
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      chosenCategory = value!;
                    });
                    refreshNews();
                  },
                ),
              ],
            ),
          ),

          // Link to news form
          if (userIsAdmin)
          ElevatedButton(
            onPressed: () async {
              final updated = await context.push('/news/create-news/');
              if (updated == true) refreshNews();
            },
            child: const Text("Create news"),
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
                        editResult: (updated) {
                          if (updated) {
                            refreshNews();
                          }
                        },
                        userIsAdmin: userIsAdmin,
                        userLoggedIn: userLoggedIn,
                      ),
                    );
                  } else {
                    return const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 12),
                          Text(
                            'No news found',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
