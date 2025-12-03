import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_detail.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_form.dart';

final String baseUrl = "https://ammar-muhammad41-pittalk.pbp.cs.ui.ac.id"; 

Map<String, String> defaultHeaders([String? token]) {
  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  if (token != null) headers['Authorization'] = 'Token $token';
  return headers;
}

class ForumListPage extends StatefulWidget {
  const ForumListPage({Key? key}) : super(key: key);

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  List<ForumResult> forums = [];
  bool loading = false;
  bool error = false;
  int page = 1;
  int totalPages = 1;
  String query = '';
  String filter = 'latest';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchForums();
  }

  Future<void> _fetchForums({int p = 1, String q = '', String filterVal = 'latest'}) async {
    setState(() {
      loading = true;
      error = false;
    });

    try {
      final uri = Uri.parse('$baseUrl/forums/api/json/').replace(queryParameters: {
        'page': p.toString(),
        'q': q,
        'filter': filterVal,
        'page_size': '9',
      });
      final resp = await http.get(uri, headers: defaultHeaders());
      if (resp.statusCode != 200) throw Exception('Failed');

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = (decoded['results'] as List<dynamic>).map((e) => ForumResult.fromJson(e as Map<String, dynamic>)).toList();

      setState(() {
        forums = results;
        page = p;
        totalPages = decoded['num_pages'] ?? 1;
      });
    } catch (e) {
      debugPrint('fetch forums error: $e');
      setState(() {
        error = true;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildCard(ForumResult f) {
    final author = f.user?.username ?? 'Anonymous';
    final created = DateFormat.yMMMd().format(f.createdAt);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ForumDetailPage(forumId: f.forumsId),
      )),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(f.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (f.isHot)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                    child: const Text('🔥 HOT', style: TextStyle(color: Colors.white, fontSize: 11)),
                  )
              ]),
              const SizedBox(height: 8),
              Text(author, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Spacer(),
              Text(f.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Text(created, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(width: 8),
                const Text('•'),
                const SizedBox(width: 8),
                Text('${f.forumsViews} views', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(width: 8),
                const Text('•'),
                const SizedBox(width: 8),
                Text('${f.forumsRepliesCounts} replies', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForumDetailPage(forumId: f.forumsId)));
                  },
                  child: const Text('Read more →'),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error) return Center(child: Text('Failed to load forums', style: TextStyle(color: Colors.red[400])));
    if (forums.isEmpty) return Center(child: Text('No discussion found'));

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: forums.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) => _buildCard(forums[i]),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: page > 1 ? () => _fetchForums(p: page - 1, q: query, filterVal: filter) : null, icon: const Icon(Icons.chevron_left)),
        Text('Page $page / $totalPages'),
        IconButton(onPressed: page < totalPages ? () => _fetchForums(p: page + 1, q: query, filterVal: filter) : null, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForumFormPage())),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(hintText: 'Search discussion...', border: OutlineInputBorder()),
                  onSubmitted: (v) {
                    query = v.trim();
                    _fetchForums(p: 1, q: query, filterVal: filter);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  query = _searchController.text.trim();
                  _fetchForums(p: 1, q: query, filterVal: filter);
                },
                child: const Text('Search'),
              )
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              const Text('Filter by:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: filter,
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('Latest')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  DropdownMenuItem(value: 'popular', child: Text('Popular')),
                  DropdownMenuItem(value: 'hot', child: Text('Hot')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  filter = v;
                  _fetchForums(p: 1, q: query, filterVal: filter);
                },
              ),
              const Spacer(),
              _buildPagination(),
            ]),
          ),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }
}

