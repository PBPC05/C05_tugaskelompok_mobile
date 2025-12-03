import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/news/data/comment_model.dart';
import 'package:pittalk_mobile/features/news/data/news_model.dart';
import 'package:pittalk_mobile/features/news/presentation/widgets/comment_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class NewsDetailPage extends StatefulWidget {
  final News news;

  const NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late News _news; // local copy of news, used to refresh etc.
  List<Comment> _comments = [];
  bool _loadingComments = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _news = widget.news;
    _incrementViews();
    _fetchComments();
  }

  Future<void> _refreshNewsData() async {
    final request = context.read<CookieRequest>();

    final response = await request.get(
      "http://localhost:8000/news/json/${_news.id}",
    );

    setState(() => _news = News.fromJson(response));
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _incrementViews() async {
    final request = context.read<CookieRequest>();
    try {
      await request.post(
        "http://localhost:8000/news/${_news.id}/increment-views/",
        {},
      );

      setState(() => _news.newsViews += 1);
    } catch (e) {
      debugPrint("Failed to increment views: $e");
    }
  }

  Future<void> _fetchComments() async {
    final request = context.read<CookieRequest>();

    try {
      final res = await request.get(
        "http://localhost:8000/news/json/${_news.id}/comments",
      );
      setState(() {
        _comments = (res as List)
            .map((json) => Comment.fromJson(json))
            .toList();
        _loadingComments = false;
      });
    } catch (e) {
      debugPrint("Failed to load comments: $e");
      setState(() => _loadingComments = false);
    }
  }

  Future<void> _postComment() async {
    final request = context.read<CookieRequest>();
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Comment cannot be blank!")));
      return;
    }

    final response = await request.postJson(
      "http://localhost:8000/news/${_news.id}/comment-flutter/",
      jsonEncode({'content': content}),
    );

    if (!context.mounted) return;

    if (response['status'] == "success") {
      _controller.clear();
      await _refreshNewsData();
      await _fetchComments();
    } else {
      debugPrint("Failed to post comment: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCatMap = {
      "all": "All Categories",
      "f1": "Formula 1/FIA",
      "championship": "Championship",
      "team": "Team",
      "driver": "Driver",
      "constructor": "Constructor",
      "race": "Race",
      "analysis": "Analysis",
      "history": "F1 History",
      "fanbase": "F1 Fanbase",
      "exclusive": "Exclusive",
      "other": "Other",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _news.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshNewsData();
          _fetchComments();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail image
              if (_news.thumbnail.isNotEmpty)
                Image.network(
                  _news.thumbnail,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Featured badge
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Text(
                            displayCatMap[_news.category]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (_news.isFeatured)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: const Text(
                              '★ Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12.0),

                    // Title
                    Text(
                      _news.title,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Author and Date
                    Row(
                      children: [
                        Text(
                          "Written by ${_news.username}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_news.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // View & comment count
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '${_news.newsViews} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4.0),
                        Text(
                          '${_news.newsComments} comments',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Full content
                    Text(
                      _news.content,
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.6,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),

                    // Comments section
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Divider(height: 24),

                    // Post new comment
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () {
                              _postComment();
                            },
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                    ),

                    // Display comments
                    if (_loadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      const Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "No comments yet",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Be the first to comment on this article.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (_, index) => CommentCard(
                          comment: _comments[index],
                          editResult: (updated) {
                            if (updated) {
                              _fetchComments();
                            }
                          },
                        ),
                      ),

                    const Divider(height: 64),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
