import '../services/api_service.dart';

class ForumService {
  /// Fetches all posts from the backend.
  static Future<List<Map<String, dynamic>>> fetchPosts({
    String? courseId,
  }) async {
    try {
      final endpoint = courseId != null
          ? '/api/posts?courseId=$courseId'
          : '/api/posts';
      final response = await ApiService.get(endpoint);
      if (response['success'] == true && response['posts'] != null) {
        return List<Map<String, dynamic>>.from(response['posts']);
      }
      return [];
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  /// Increments view count for a post.
  static Future<void> incrementViewCount({required String postId}) async {
    try {
      await ApiService.post('/api/posts/view', {'postId': postId});
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// Fetches comments for a specific post.
  static Future<List<Map<String, dynamic>>> fetchComments({
    required String postId,
  }) async {
    try {
      final response = await ApiService.get(
        '/api/posts/comments?postId=$postId',
      );
      if (response['success'] == true && response['comments'] != null) {
        return List<Map<String, dynamic>>.from(response['comments']);
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  /// Creates a new post.
  static Future<Map<String, dynamic>?> createPost({
    required String authorId,
    required String authorName,
    required String avatarEmoji,
    required String title,
    required String content,
    required List<String> tags,
    String? courseId,
  }) async {
    try {
      final response = await ApiService.post('/api/posts', {
        'authorId': authorId,
        'authorName': authorName,
        'avatarEmoji': avatarEmoji,
        'courseId': courseId ?? '',
        'title': title,
        'content': content,
        'tags': tags,
      });
      if (response['success'] == true && response['post'] != null) {
        return Map<String, dynamic>.from(response['post']);
      }
      return null;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  /// Votes on a post.
  static Future<Map<String, dynamic>?> votePost({
    required String postId,
    required String userId,
    required String voteType, // "up" or "down"
  }) async {
    try {
      final response = await ApiService.post('/api/posts/vote', {
        'postId': postId,
        'userId': userId,
        'voteType': voteType,
      });
      if (response['success'] == true) {
        return {
          'upvotes': response['upvotes'] ?? 0,
          'downvotes': response['downvotes'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error voting on post: $e');
      return null;
    }
  }

  /// Adds a comment to a post.
  static Future<Map<String, dynamic>?> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String avatarEmoji,
    required String content,
  }) async {
    try {
      final response = await ApiService.post('/api/posts/comment', {
        'postId': postId,
        'authorId': authorId,
        'authorName': authorName,
        'avatarEmoji': avatarEmoji,
        'content': content,
      });
      if (response['success'] == true && response['comment'] != null) {
        return Map<String, dynamic>.from(response['comment']);
      }
      return null;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  /// Votes on a comment.
  static Future<Map<String, dynamic>?> voteComment({
    required String commentId,
    required String userId,
    required String voteType, // "up" or "down"
  }) async {
    try {
      final response = await ApiService.post('/api/posts/comment/vote', {
        'commentId': commentId,
        'userId': userId,
        'voteType': voteType,
      });
      if (response['success'] == true) {
        return {
          'upvotes': response['upvotes'] ?? 0,
          'downvotes': response['downvotes'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error voting on comment: $e');
      return null;
    }
  }
}
