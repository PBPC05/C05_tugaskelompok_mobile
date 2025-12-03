import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
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

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  const ForumDetailPage({Key? key, required this.forumId}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  ForumResult? forum;
  bool loading = true;
  bool err = false;
  List<ReplyResult> replies = [];
  int repliesOffset = 0;
  final int repliesLimit = 5;
  final TextEditingController _replyController = TextEditingController();
  bool userHasLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadReplies();
  }

  Future<void> _loadDetail() async {
    setState(() => loading = true);
    try {
      final uri = Uri.parse('$baseUrl/forums/api/json/').replace(queryParameters: {'page_size': '1', 'q': '', 'filter': 'latest'});
      final resp = await http.get(Uri.parse('$baseUrl/forums/${widget.forumId}/json/'), headers: defaultHeaders());
      if (resp.statusCode != 200) {
        final listResp = await http.get(uri, headers: defaultHeaders());
        if (listResp.statusCode == 200) {
          final decoded = jsonDecode(listResp.body);
          final found = (decoded['results'] as List).where((r) => (r['forums_id'] ?? r['id']) == widget.forumId).toList();
          if (found.isNotEmpty) {
            forum = ForumResult.fromJson(found.first as Map<String, dynamic>);
          }
        } else {
          throw Exception('not found');
        }
      } else {
        final decoded = jsonDecode(resp.body);
        forum = ForumResult.fromJson(decoded as Map<String, dynamic>);
      }

      if (forum != null) {
        likeCount = forum!.forumsLikes.length;
      }
    } catch (e) {
      debugPrint('load detail error: $e');
      setState(() => err = true);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadReplies({bool append = false}) async {
    try {
      final uri = Uri.parse('$baseUrl/forums/${widget.forumId}/replies/json/').replace(queryParameters: {
        'offset': repliesOffset.toString(),
        'limit': repliesLimit.toString(),
      });
      final resp = await http.get(uri, headers: defaultHeaders());
      if (resp.statusCode != 200) throw Exception('failed load replies');
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = (decoded['replies'] ?? decoded['results'] ?? []) as List;
      final parsed = list.map((e) => ReplyResult.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        if (append) replies.addAll(parsed);
        else replies = parsed;
        repliesOffset += parsed.length;
      });
    } catch (e) {
      debugPrint('load replies error: $e');
    }
  }

  Future<void> _postReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;
    try {
      final uri = Uri.parse('$baseUrl/forums/${widget.forumId}/reply/create/json/');
      final resp = await http.post(uri,
          headers: defaultHeaders(), body: jsonEncode({'replies_content': content}));
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final r = ReplyResult.fromJson(decoded as Map<String, dynamic>);
        setState(() {
          replies.insert(0, r);
          _replyController.clear();
          forum = forum == null ? forum : ForumResult(
            forumsId: forum!.forumsId,
            title: forum!.title,
            content: forum!.content,
            forumsViews: forum!.forumsViews,
            forumsRepliesCounts: forum!.forumsRepliesCounts + 1,
            isHot: forum!.isHot,
            createdAt: forum!.createdAt,
            updatedAt: forum!.updatedAt,
            forumsLikes: forum!.forumsLikes,
            user: forum!.user,
          );
        });
      } else {
        final decoded = jsonDecode(resp.body);
        debugPrint('post reply error body: $decoded');
      }
    } catch (e) {
      debugPrint('post reply error: $e');
    }
  }

  Future<void> _toggleForumLike() async {
    try {
      final uri = Uri.parse('$baseUrl/forums/${widget.forumId}/like/json/');
      final resp = await http.post(uri, headers: defaultHeaders());
      if (resp.statusCode == 200) {
        final d = jsonDecode(resp.body);
        setState(() {
          likeCount = d['forums_likes'] ?? d['likes'] ?? likeCount;
          userHasLiked = d['user_has_liked'] ?? !userHasLiked;
        });
      }
    } catch (e) {
      debugPrint('toggle like: $e');
    }
  }

  Future<void> _toggleReplyLike(int replyId, int index) async {
  try {
    final uri = Uri.parse('$baseUrl/forums/reply/$replyId/like/');
    final resp = await http.post(uri, headers: defaultHeaders());

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);

      setState(() {
        replies[index] = replies[index].copyWith(
          likes: List<int>.from(json['likes'] ?? replies[index].repliesLikes),
          userHasLiked: json['user_has_liked'] ?? !replies[index].userHasLiked,
        );
      });
    }
  } catch (e) {
    debugPrint('toggle reply like error: $e');
  }
}


  Future<void> _deleteReply(int replyId) async {
    try {
      final uri = Uri.parse('$baseUrl/forums/reply/$replyId/delete/');
      final resp = await http.post(uri, headers: defaultHeaders());
      if (resp.statusCode == 200) {
        setState(() {
          replies.removeWhere((r) => r.id == replyId);
          if (forum != null) {
            forum = ForumResult(
              forumsId: forum!.forumsId,
              title: forum!.title,
              content: forum!.content,
              forumsViews: forum!.forumsViews,
              forumsRepliesCounts: forum!.forumsRepliesCounts - 1,
              isHot: forum!.isHot,
              createdAt: forum!.createdAt,
              updatedAt: forum!.updatedAt,
              forumsLikes: forum!.forumsLikes,
              user: forum!.user,
            );
          }
        });
      } else {
        debugPrint('delete failed ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('delete reply error: $e');
    }
  }

  Widget _buildReplyTile(ReplyResult r, int idx) {
    final author = r.user?.username ?? 'Anonymous';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(child: Text(author.isNotEmpty ? author[0].toUpperCase() : 'A')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(author, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(timeAgo(r.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ]),
              const SizedBox(height: 6),
              Text(r.repliesContent),
              const SizedBox(height: 8),
              Row(children: [
                Text('${r.repliesLikes.length} ❤️'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _toggleReplyLike(r.id, idx),
                  child: Text(r.userHasLiked ? '👎 Unlike' : '👍 Like'),
                ),
                const SizedBox(width: 8),
                if (r.isOwner || r.isForumOwner) 
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete reply?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) _deleteReply(r.id);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  )
              ]),
            ]),
          )
        ]),
      ),
    );
  }

  String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final title = forum?.title ?? 'Forum';
    final author = forum?.user?.username ?? 'Anonymous';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err
              ? Center(child: Text('Failed to load', style: TextStyle(color: Colors.red[400])))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(forum!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                            if (forum!.isHot) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.yellow[700], borderRadius: BorderRadius.circular(8)),
                              child: const Text('HOT', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text('by $author', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(width: 8),
                            const Text('•'),
                            const SizedBox(width: 8),
                            Text(timeAgo(forum!.createdAt), style: TextStyle(color: Colors.grey[600])),
                            const Spacer(),
                            Text('$likeCount likes', style: TextStyle(color: Colors.grey[600])),
                          ]),
                          const SizedBox(height: 12),
                          Text(forum!.content),
                          const SizedBox(height: 12),
                          Row(children: [
                            ElevatedButton(
                              onPressed: _toggleForumLike,
                              child: Text(userHasLiked ? '👎 Unlike' : '👍 Like'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForumFormPage(editForum: forum))),
                              child: const Text('Edit'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), // Edit
                            ),
                          ])
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Replies (${forum!.forumsRepliesCounts})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          TextField(
                            controller: _replyController,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(hintText: 'Write your reply...'),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(onPressed: _postReply, child: const Text('Post Reply')),
                          )
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(children: replies.asMap().entries.map((e) => _buildReplyTile(e.value, e.key)).toList()),
                    if (replies.length >= repliesLimit)
                      TextButton(
                        onPressed: () => _loadReplies(append: true),
                        child: const Text('Load more'),
                      ),
                  ]),
                ),
    );
  }
}