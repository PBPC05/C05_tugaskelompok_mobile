import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pittalk_mobile/features/forums/data/forums_api.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';
import 'package:pittalk_mobile/features/forums/data/forums_replies_model.dart';
import 'package:pittalk_mobile/features/forums/presentation/screens/forums_form.dart';
import 'package:pittalk_mobile/features/forums/presentation/widget/forums_replies_card.dart';

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  final CookieRequest request;

  const ForumDetailPage({
    Key? key,
    required this.forumId,
    required this.request,
  }) : super(key: key);

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _replyController = TextEditingController();
  final _replyFocusNode = FocusNode();

  Forum? _forum;
  List<ForumReply> _replies = [];
  bool _isLoading = true;
  bool _isPostingReply = false;
  bool _isLoadingReplies = false;
  bool _hasError = false;
  
  // User states
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isOwner = false;
  String? _currentUsername;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadForumData();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkUserStatus() async {
    try {
      final apiService = ForumsApiService();
      
      // Get user profile
      final userData = await apiService.getUserProfile(
        request: widget.request,
      );
      
      if (userData['is_logged_in'] == true) {
        _isLoggedIn = true;
        _currentUsername = userData['username'];
        _currentUserId = userData['id'];
        _isAdmin = (userData['is_staff'] ?? false) || (userData['is_superuser'] ?? false);
        
        // Also check admin status via check-admin endpoint for admin features
        try {
          final adminData = await apiService.checkAdmin(
            request: widget.request,
          );
          _isAdmin = adminData['is_admin'] ?? _isAdmin;
        } catch (e) {
          print('Error checking admin status: $e');
        }
        
        setState(() {});
        
        // Check ownership after loading forum
        if (_forum != null) {
          await _checkOwnership();
        }
      }
    } catch (e) {
      print('Error checking user status: $e');
      _isLoggedIn = false;
    }
  }

  Future<void> _checkOwnership() async {
    if (_forum == null || !_isLoggedIn) return;
    
    try {
      // Check by user ID (most reliable)
      if (_currentUserId != null && _forum!.userId != null) {
        _isOwner = _forum!.userId == _currentUserId.toString();
      }
      
      // Check by username (fallback)
      if (!_isOwner && _currentUsername != null && _forum!.username != null) {
        _isOwner = _forum!.username!.toLowerCase() == _currentUsername!.toLowerCase();
      }
      
      setState(() {});
    } catch (e) {
      print('Error checking ownership: $e');
    }
  }

  Future<void> _loadForumData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final apiService = ForumsApiService();
      final forum = await apiService.getForum(
        request: widget.request,
        id: widget.forumId,
      );
      final replies = await apiService.getForumReplies(
        request: widget.request,
        forumId: widget.forumId,
      );
      
      setState(() {
        _forum = forum;
        _replies = replies;
        _isLoading = false;
      });
      
      // Check ownership if user is already logged in
      if (_isLoggedIn) {
        await _checkOwnership();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showErrorSnackbar('Failed to load forum: ${e.toString()}');
      print('Error loading forum: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (_forum == null) return;
    
    if (!_isLoggedIn) {
      _showErrorSnackbar('Please login to like this forum');
      return;
    }

    try {
      final apiService = ForumsApiService();
      final result = await apiService.toggleForumLike(
        request: widget.request,
        id: _forum!.id,
      );
      setState(() {
        _forum = Forum.fromJson({
          ..._forum!.toJson(),
          'likes': result['forums_likes'] ?? result['likes'] ?? _forum!.likes,
          'user_has_liked': result['user_has_liked'] ?? false,
        });
      });
    } catch (e) {
      _showErrorSnackbar('Failed to like: ${e.toString()}');
      print('Error toggling like: $e');
    }
  }

  Future<void> _postReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) {
      _showErrorSnackbar('Please enter a reply');
      return;
    }

    if (!_isLoggedIn) {
      _showErrorSnackbar('Please login to post a reply');
      return;
    }

    setState(() {
      _isPostingReply = true;
    });

    try {
      final apiService = ForumsApiService();
      final newReply = await apiService.createReply(
        request: widget.request,
        forumId: widget.forumId,
        content: content,
      );

      setState(() {
        _replies.insert(0, newReply);
        _replyController.clear();
        if (_forum != null) {
          _forum = Forum.fromJson({
            ..._forum!.toJson(),
            'repliesCount': _forum!.repliesCount + 1,
          });
        }
      });
      _replyFocusNode.unfocus();
      _showSuccessSnackbar('Reply posted successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to post reply: ${e.toString()}');
      print('Error posting reply: $e');
    } finally {
      setState(() {
        _isPostingReply = false;
      });
    }
  }

  Future<void> _toggleReplyLike(int replyId) async {
    if (!_isLoggedIn) {
      _showErrorSnackbar('Please login to like replies');
      return;
    }

    try {
      final apiService = ForumsApiService();
      final result = await apiService.toggleReplyLike(
        request: widget.request,
        replyId: replyId,
      );
      setState(() {
        final index = _replies.indexWhere((r) => r.id == replyId);
        if (index != -1) {
          _replies[index] = ForumReply.fromJson({
            ..._replies[index].toJson(),
            'likes': result['likes'] ?? 0,
            'user_has_liked': result['user_has_liked'] ?? false,
          });
        }
      });
    } catch (e) {
      _showErrorSnackbar('Failed to like reply: ${e.toString()}');
      print('Error toggling reply like: $e');
    }
  }

  Future<void> _deleteReply(int replyId) async {
    if (!_isLoggedIn) {
      _showErrorSnackbar('Please login to delete replies');
      return;
    }

    // Check if user can delete this reply
    final reply = _replies.firstWhere((r) => r.id == replyId, orElse: () => ForumReply(
      id: 0,
      username: '',
      content: '',
      likes: 0,
      createdAt: DateTime.now(),
      userHasLiked: false,
      isOwner: false,
      isForumOwner: false,
    ));
    
    final canDelete = reply.isOwner || _isOwner || _isAdmin;
    
    if (!canDelete) {
      _showErrorSnackbar('You are not authorized to delete this reply');
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
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
        final apiService = ForumsApiService();
        final success = await apiService.deleteReply(
          request: widget.request,
          replyId: replyId,
        );
        if (success) {
          setState(() {
            _replies.removeWhere((r) => r.id == replyId);
            if (_forum != null) {
              _forum = Forum.fromJson({
                ..._forum!.toJson(),
                'repliesCount': _forum!.repliesCount - 1,
              });
            }
          });
          _showSuccessSnackbar('Reply deleted successfully');
        }
      } catch (e) {
        _showErrorSnackbar('Failed to delete reply: ${e.toString()}');
        print('Error deleting reply: $e');
      }
    }
  }

  Future<void> _deleteForum() async {
    if (!_isLoggedIn) {
      _showErrorSnackbar('Please login to delete forums');
      return;
    }

    if (!_isOwner && !_isAdmin) {
      _showErrorSnackbar('You are not authorized to delete this forum');
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forum'),
        content: const Text('Are you sure you want to delete this forum?'),
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
        final apiService = ForumsApiService();
        final success = await apiService.deleteForum(
          request: widget.request,
          id: widget.forumId,
        );
        if (success) {
          Navigator.pop(context, true);
          _showSuccessSnackbar('Forum deleted successfully');
        }
      } catch (e) {
        _showErrorSnackbar('Failed to delete forum: ${e.toString()}');
        print('Error deleting forum: $e');
      }
    }
  }

  Future<void> _toggleHotStatus() async {
    if (_forum == null) return;

    if (!_isAdmin) {
      _showErrorSnackbar('Only administrators can toggle hot status');
      return;
    }

    try {
      final apiService = ForumsApiService();
      final result = await apiService.toggleHotStatus(
        request: widget.request,
        forumId: _forum!.id,
      );
      setState(() {
        _forum = Forum.fromJson({
          ..._forum!.toJson(),
          'is_hot': result['is_hot'] ?? false,
        });
      });
      _showSuccessSnackbar(
        _forum!.isHot ? 'Forum marked as HOT' : 'Forum unmarked from HOT',
      );
    } catch (e) {
      _showErrorSnackbar('Failed to change HOT status: ${e.toString()}');
      print('Error toggling hot status: $e');
    }
  }

  Future<void> _editForum() async {
    if (_forum == null) return;

    if (!_isOwner) {
      _showErrorSnackbar('Only the forum owner can edit this forum');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForumFormPage(
          request: widget.request,
          forum: _forum,
          isEdit: true,
        ),
      ),
    );

    if (result == true) {
      await _loadForumData();
      _showSuccessSnackbar('Forum updated successfully');
    }
  }

  Future<void> _loadMoreReplies() async {
    if (_forum == null) return;

    setState(() {
      _isLoadingReplies = true;
    });

    try {
      final apiService = ForumsApiService();
      final newReplies = await apiService.loadMoreReplies(
        request: widget.request,
        forumId: _forum!.id,
        offset: _replies.length,
      );
      
      setState(() {
        _replies.addAll(newReplies);
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load more replies: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingReplies = false;
      });
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
    return Center(
      child: Column(
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
            child: const Text('Go Back'),
          ),
        ],
      ),
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
                            
                            // Check if current user is the reply owner
                            final isReplyOwner = _isLoggedIn && 
                                _currentUsername != null && 
                                reply.username == _currentUsername;
                            
                            return ForumsRepliesCard(
                              reply: reply.copyWith(
                                isOwner: isReplyOwner,
                                isForumOwner: _isOwner,
                              ),
                              isAdmin: _isAdmin,
                              isLoggedIn: _isLoggedIn,
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
                          onPressed: _isLoadingReplies ? null : _loadMoreReplies,
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
                              : const Text('Load More Replies'),
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

  Widget _buildActionButtons() {
    final canEdit = _isOwner;
    final canDelete = _isOwner || _isAdmin;
    final canToggleHot = _isAdmin;
    
    if (!canEdit && !canDelete && !canToggleHot) {
      return const SizedBox();
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canEdit)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editForum,
          ),
        if (canDelete)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteForum,
          ),
        if (canToggleHot)
          IconButton(
            icon: Icon(
              _forum!.isHot
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              color: _forum!.isHot ? Colors.orange : Colors.white,
            ),
            onPressed: _toggleHotStatus,
          ),
      ],
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
                  _forum!.username?[0].toUpperCase() ?? 'A',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _forum!.username ?? 'Anonymous',
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
              onPressed: _isLoggedIn ? _toggleLike : () {
                _showErrorSnackbar('Please login to like this forum');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoggedIn
                  ? (_forum!.userHasLiked ? Colors.red[800] : Colors.red[700])
                  : Colors.grey[700],
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
                hintText: _isLoggedIn ? 'Write your reply...' : 'Login to reply',
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
              enabled: _isLoggedIn,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoggedIn && !_isPostingReply ? _postReply : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoggedIn ? Colors.red[700] : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isPostingReply
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLoggedIn ? 'Post Reply' : 'Login to Reply'),
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