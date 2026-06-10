import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../services/api_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<CommunityPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _posts = [];
      _hasMore = true;
    }
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    try {
      final newPosts = await ApiService.getCommunityPosts(page: _page);
      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        _posts.addAll(newPosts);
        _page++;
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost(CommunityPost post, String token) async {
    try {
      final created = await ApiService.createPost(post, token);
      _posts.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePost(String postId, String token) async {
    try {
      await ApiService.deletePost(postId, token);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likePost(String postId, String userId, String token) async {
    try {
      await ApiService.likePost(postId, userId, token);
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx] = _posts[idx].copyWith(
          likes: _posts[idx].likes + 1,
          isLikedByMe: true,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
