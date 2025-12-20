import 'package:flutter/foundation.dart';
import 'package:pittalk_mobile/features/forums/data/forums_model.dart';

class ForumStateManager extends ChangeNotifier {
  final Map<String, Forum> _forumCache = {};
  bool _needsRefresh = false;

  void cacheForum(Forum forum) {
    _forumCache[forum.id] = forum;
    notifyListeners();
  }

  Forum? getCachedForum(String forumId) {
    return _forumCache[forumId];
  }

  void updateForum(String forumId, Forum updatedForum) {
    _forumCache[forumId] = updatedForum;
    _needsRefresh = true;
    notifyListeners();
  }

  void updateForumLikes(String forumId, int likes, bool userHasLiked) {
    final forum = _forumCache[forumId];
    if (forum != null) {
      _forumCache[forumId] = Forum(
        id: forum.id,
        userId: forum.userId,
        username: forum.username,
        title: forum.title,
        content: forum.content,
        views: forum.views,
        likes: likes,
        repliesCount: forum.repliesCount,
        isHot: forum.isHot,
        createdAt: forum.createdAt,
        updatedAt: forum.updatedAt,
        userHasLiked: userHasLiked,
      );
      _needsRefresh = true;
      notifyListeners();
    }
  }
  
  void updateForumRepliesCount(String forumId, int repliesCount) {
    final forum = _forumCache[forumId];
    if (forum != null) {
      _forumCache[forumId] = Forum(
        id: forum.id,
        userId: forum.userId,
        username: forum.username,
        title: forum.title,
        content: forum.content,
        views: forum.views,
        likes: forum.likes,
        repliesCount: repliesCount,
        isHot: forum.isHot,
        createdAt: forum.createdAt,
        updatedAt: forum.updatedAt,
        userHasLiked: forum.userHasLiked,
      );
      _needsRefresh = true;
      notifyListeners();
    }
  }

  void updateForumViewCount(String forumId, int views) {
    final forum = _forumCache[forumId];
    if (forum != null) {
      _forumCache[forumId] = Forum(
        id: forum.id,
        userId: forum.userId,
        username: forum.username,
        title: forum.title,
        content: forum.content,
        views: views,
        likes: forum.likes,
        repliesCount: forum.repliesCount,
        isHot: forum.isHot,
        createdAt: forum.createdAt,
        updatedAt: forum.updatedAt,
        userHasLiked: forum.userHasLiked,
      );
      _needsRefresh = true;
      notifyListeners();
    }
  }
  
  void updateForumHotStatus(String forumId, bool isHot) {
    final forum = _forumCache[forumId];
    if (forum != null) {
      _forumCache[forumId] = Forum(
        id: forum.id,
        userId: forum.userId,
        username: forum.username,
        title: forum.title,
        content: forum.content,
        views: forum.views,
        likes: forum.likes,
        repliesCount: forum.repliesCount,
        isHot: isHot,
        createdAt: forum.createdAt,
        updatedAt: forum.updatedAt,
        userHasLiked: forum.userHasLiked,
      );
      _needsRefresh = true;
      notifyListeners();
    }
  }

  void removeForum(String forumId) {
    _forumCache.remove(forumId);
    _needsRefresh = true;
    notifyListeners();
  }

  bool get needsRefresh => _needsRefresh;

  void resetRefreshFlag() {
    _needsRefresh = false;
  }

  void clearCache() {
    _forumCache.clear();
    _needsRefresh = false;
    notifyListeners();
  }
}