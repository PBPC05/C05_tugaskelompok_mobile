import 'package:flutter/material.dart';
import 'package:pittalk_mobile/features/forums/data/forums_api.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_form.dart';
import 'package:pittalk_mobile/features/forums/presentation/widget/forums_replies_card.dart';

class ForumDetailPage extends StatefulWidget {
  final String forumId;

  const ForumDetailPage({Key? key, required this.forumId}) : super(key: key);

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final ForumsApiService _apiService = ForumsApiService();
  final TextEditingController _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();

  Forum? _forum;
  List<ForumReply> _replies = [];
  bool _isLoading = true;
  bool _isPostingReply = false;
  int _currentReplyPage = 1;
  int _totalReplyPages = 1;
  bool _isLoadingReplies = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadForumData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final forum = await _apiService.getForum(widget.forumId);
      setState(() {
        _forum = forum;
        _isLoading = false;
      });
      _loadReplies();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showErrorSnackbar('Failed to load forum: ${e.toString()}');
    }
  }

  Future<void> _loadReplies({int page = 1, bool reset = true}) async {
    if (_forum == null) return;

    setState(() {
      _isLoadingReplies = true;
    });

    try {
      final newReplies = await _apiService.loadMoreReplies(
        _forum!.id,
        reset ? 0 : _replies.length,
      );

      setState(() {
        if (reset) {
          _replies = newReplies;
          _currentReplyPage = 1;
        } else {
          _replies.addAll(newReplies);
          _currentReplyPage++;
        }
        _isLoadingReplies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReplies = false;
      });
      _showErrorSnackbar('Failed to load replies: ${e.toString()}');
    }
  }

  Future<void> _toggleLike() async {
    if (_forum == null) return;

    try {
      final result = await _apiService.toggleForumLike(_forum!.id);
      setState(() {
        _forum = Forum.fromJson({
          ..._forum!.toJson(),
          'forums_likes': result['forums_likes'],
          'user_has_liked': result['user_has_liked'],
        });
      });
    } catch (e) {
      _showErrorSnackbar('Failed to likes: ${e.toString()}');
    }
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      _isPostingReply = true;
    });

    try {
      final newReply = await _apiService.createReply(
        widget.forumId,
        _replyController.text.trim(),
      );

      setState(() {
        _replies.insert(0, newReply);
        _replyController.clear();
        if (_forum != null) {
          _forum = Forum.fromJson({
            ..._forum!.toJson(),
            'forums_replies_counts': _forum!.repliesCount + 1,
          });
        }
      });
      _replyFocusNode.unfocus();
    } catch (e) {
      _showErrorSnackbar('Failed to post replies: ${e.toString()}');
    } finally {
      setState(() {
        _isPostingReply = false;
      });
    }
  }

  Future<void> _toggleReplyLike(int replyId) async {
    try {
      final result = await _apiService.toggleReplyLike(replyId);
      setState(() {
        final index = _replies.indexWhere((r) => r.id == replyId);
        if (index != -1) {
          _replies[index] = ForumReply.fromJson({
            ..._replies[index].toJson(),
            'likes': result['likes'],
            'user_has_liked': result['user_has_liked'],
          });
        }
      });
    } catch (e) {
      _showErrorSnackbar('Failed to like replies: ${e.toString()}');
    }
  }

  Future<void> _deleteReply(int replyId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Do you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteReply(replyId);
        setState(() {
          _replies.removeWhere((r) => r.id == replyId);
          if (_forum != null) {
            _forum = Forum.fromJson({
              ..._forum!.toJson(),
              'forums_replies_counts': _forum!.repliesCount - 1,
            });
          }
        });
        _showSuccessSnackbar('Reply deleted successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to delete reply: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteForum() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HDelete Forum'),
        content: const Text('Do you want to delete this forum?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteForum(widget.forumId);
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackbar('Failed to delete forums: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30} months ago';
    return '${difference.inDays ~/ 365} years ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forum == null
              ? _buildErrorView()
              : _buildForumContent(),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Forum not found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildForumContent() {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Discussion',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),

          // Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Forum Content
                SliverToBoxAdapter(
                  child: _buildForumHeader(),
                ),

                // Replies Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Replies (${_forum!.repliesCount})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isLoadingReplies)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),

                // Replies List
                _replies.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.comment_outlined,
                                  color: Colors.grey[600], size: 64),
                              const SizedBox(height: 16),
                              const Text(
                                'No replies yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Be the first to reply!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reply = _replies[index];
                            return ForumsRepliesCard(
                              reply: reply,
                              onLike: () => _toggleReplyLike(reply.id),
                              onDelete: () => _deleteReply(reply.id),
                            );
                          },
                          childCount: _replies.length,
                        ),
                      ),

                // Load More Button
                if (_forum!.repliesCount > _replies.length)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _isLoadingReplies ? null : () => _loadReplies(reset: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoadingReplies
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Load more'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Reply Input
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildForumHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _forum!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Author and Time
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[700],
                radius: 20,
                child: Text(
                  _forum!.username![0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _forum!.username!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(_forum!.createdAt),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_forum!.isHot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'HOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.remove_red_eye, '${_forum!.views}'),
              _buildStatItem(Icons.favorite, '${_forum!.likes}'),
              _buildStatItem(Icons.comment, '${_forum!.repliesCount}'),
            ],
          ),
          const SizedBox(height: 20),

          // Content
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[800]!),
                bottom: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Text(
              _forum!.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Like Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleLike,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _forum!.userHasLiked ? Colors.red[800] : Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(
                _forum!.userHasLiked ? Icons.thumb_down : Icons.thumb_up,
              ),
              label: Text(_forum!.userHasLiked ? 'Unlike' : 'Like'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // In real app, check if current user is owner or staff
    final isOwner = true; // Replace with actual check
    final isStaff = true; // Replace with actual check

    if (!isOwner && !isStaff) return const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ForumFormPage(
                    forum: _forum,
                    isEdit: true,
                  ),
                ),
              );
              if (result == true) {
                _loadForumData();
              }
            },
          ),
        if (isOwner || isStaff)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteForum,
          ),
        if (isStaff)
          IconButton(
            icon: Icon(
              _forum!.isHot
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              color: _forum!.isHot ? Colors.orange : Colors.white,
            ),
            onPressed: () async {
              try {
                final result = await _apiService.toggleHotStatus(_forum!.id);
                setState(() {
                  _forum = Forum.fromJson({
                    ..._forum!.toJson(),
                    'is_hot': result['is_hot'],
                  });
                });
                _showSuccessSnackbar(
                  result['is_hot'] ? 'Forum marked HOT' : 'HOT unmarked',
                );
              } catch (e) {
                _showErrorSnackbar('Failed to change HOT status');
              }
            },
          ),
      ],
    );
  }

  Widget _buildReplyInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[900],
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Write your reply...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPostingReply ? null : _postReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isPostingReply
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post reply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400]),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}