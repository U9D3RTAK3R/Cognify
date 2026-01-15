import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/forum_service.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final String avatarEmoji;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final List<Comment> comments;
  final List<String> tags;
  final Set<String> upvotedBy;
  final Set<String> downvotedBy;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.avatarEmoji,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    this.viewCount = 0,
    required this.createdAt,
    this.comments = const [],
    this.tags = const [],
    Set<String>? upvotedBy,
    Set<String>? downvotedBy,
  }) : upvotedBy = upvotedBy ?? {},
       downvotedBy = downvotedBy ?? {};

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] ?? json['ID'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      content: json['content'] ?? json['Content'] ?? '',
      author: json['authorName'] ?? json['AuthorName'] ?? 'Unknown',
      avatarEmoji: json['avatarEmoji'] ?? json['AvatarEmoji'] ?? '🧑',
      upvotes: json['upvotes'] ?? json['Upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? json['Downvotes'] ?? 0,
      commentCount: json['commentCount'] ?? json['CommentCount'] ?? 0,
      viewCount: json['viewCount'] ?? json['ViewCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['CreatedAt'] != null
                ? DateTime.tryParse(json['CreatedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
      tags: List<String>.from(json['tags'] ?? json['Tags'] ?? []),
      upvotedBy: Set<String>.from(json['upvotedBy'] ?? json['UpvotedBy'] ?? []),
      downvotedBy: Set<String>.from(
        json['downvotedBy'] ?? json['DownvotedBy'] ?? [],
      ),
    );
  }

  ForumPost copyWith({
    int? upvotes,
    int? downvotes,
    int? commentCount,
    int? viewCount,
    List<Comment>? comments,
    List<String>? tags,
    Set<String>? upvotedBy,
    Set<String>? downvotedBy,
  }) {
    return ForumPost(
      id: id,
      title: title,
      content: content,
      author: author,
      avatarEmoji: avatarEmoji,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
    );
  }

  bool hasUserUpvoted(String userId) => upvotedBy.contains(userId);
  bool hasUserDownvoted(String userId) => downvotedBy.contains(userId);
}

class Comment {
  final String id;
  final String text;
  final String author;
  final String avatarEmoji;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final List<Comment> replies;
  final Set<String> upvotedBy;
  final Set<String> downvotedBy;
  final String? parentId;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.avatarEmoji,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.createdAt,
    this.replies = const [],
    Set<String>? upvotedBy,
    Set<String>? downvotedBy,
    this.parentId,
  }) : upvotedBy = upvotedBy ?? {},
       downvotedBy = downvotedBy ?? {};

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? json['ID'] ?? '',
      text: json['content'] ?? json['Content'] ?? '',
      author: json['authorName'] ?? json['AuthorName'] ?? 'Unknown',
      avatarEmoji: json['avatarEmoji'] ?? json['AvatarEmoji'] ?? '🧑',
      upvotes: json['upvotes'] ?? json['Upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? json['Downvotes'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['CreatedAt'] != null
                ? DateTime.tryParse(json['CreatedAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
      upvotedBy: Set<String>.from(json['upvotedBy'] ?? json['UpvotedBy'] ?? []),
      downvotedBy: Set<String>.from(
        json['downvotedBy'] ?? json['DownvotedBy'] ?? [],
      ),
    );
  }

  // Legacy getter for backwards compatibility
  int get votes => upvotes - downvotes;

  Comment copyWith({
    String? text,
    int? upvotes,
    int? downvotes,
    List<Comment>? replies,
    Set<String>? upvotedBy,
    Set<String>? downvotedBy,
  }) {
    return Comment(
      id: id,
      text: text ?? this.text,
      author: author,
      avatarEmoji: avatarEmoji,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt,
      replies: replies ?? this.replies,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      parentId: parentId,
    );
  }
}

class ForumState {
  final List<ForumPost> posts;
  final String sortBy;
  final String currentUserId;
  final Set<String> savedPostIds;
  final bool isLoading;
  final String? error;

  ForumState({
    required this.posts,
    this.sortBy = 'hot',
    this.currentUserId = 'currentUser',
    Set<String>? savedPostIds,
    this.isLoading = false,
    this.error,
  }) : savedPostIds = savedPostIds ?? {};

  ForumState copyWith({
    List<ForumPost>? posts,
    String? sortBy,
    Set<String>? savedPostIds,
    bool? isLoading,
    String? error,
  }) {
    return ForumState(
      posts: posts ?? this.posts,
      sortBy: sortBy ?? this.sortBy,
      currentUserId: currentUserId,
      savedPostIds: savedPostIds ?? this.savedPostIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ForumController extends Notifier<ForumState> {
  @override
  ForumState build() {
    // Fetch posts and saved post IDs on initialization
    _fetchPosts();
    _loadSavedPostIds();
    return ForumState(posts: [], isLoading: true);
  }

  Future<void> _loadSavedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_post_ids') ?? [];
    state = state.copyWith(savedPostIds: Set<String>.from(savedList));
  }

  Future<void> _saveSavedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_post_ids', state.savedPostIds.toList());
  }

  Future<void> _fetchPosts() async {
    try {
      final postsData = await ForumService.fetchPosts();
      final posts = postsData.map((data) => ForumPost.fromJson(data)).toList();
      state = state.copyWith(posts: posts, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshPosts() async {
    state = state.copyWith(isLoading: true);
    await _fetchPosts();
  }

  /// Fetches comments for a specific post from backend and updates state.
  Future<void> fetchCommentsForPost(String postId) async {
    try {
      final commentsData = await ForumService.fetchComments(postId: postId);
      final comments = commentsData
          .map((data) => Comment.fromJson(data))
          .toList();

      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id == postId) {
            return p.copyWith(
              comments: comments,
              commentCount: comments.length,
            );
          }
          return p;
        }).toList(),
      );
    } catch (e) {
      // Silently fail - comments will just be empty
      print('Error fetching comments: $e');
    }
  }

  /// Increments view count for a post via backend API.
  Future<void> incrementViewCount(String postId) async {
    // Call API in background
    await ForumService.incrementViewCount(postId: postId);

    // Update local state
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(viewCount: p.viewCount + 1);
        }
        return p;
      }).toList(),
    );
  }

  Future<void> upvote(String postId) async {
    final userId = state.currentUserId;

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          if (p.upvotedBy.contains(userId)) return p; // Already upvoted
          final newUpvotedBy = Set<String>.from(p.upvotedBy)..add(userId);
          final newDownvotedBy = Set<String>.from(p.downvotedBy)
            ..remove(userId);
          return p.copyWith(
            upvotes: p.upvotes + 1,
            downvotes: p.downvotedBy.contains(userId)
                ? p.downvotes - 1
                : p.downvotes,
            upvotedBy: newUpvotedBy,
            downvotedBy: newDownvotedBy,
          );
        }
        return p;
      }).toList(),
    );

    // Call API in background
    await ForumService.votePost(postId: postId, userId: userId, voteType: 'up');
  }

  Future<void> downvote(String postId) async {
    final userId = state.currentUserId;

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          if (p.downvotedBy.contains(userId)) return p; // Already downvoted
          final newDownvotedBy = Set<String>.from(p.downvotedBy)..add(userId);
          final newUpvotedBy = Set<String>.from(p.upvotedBy)..remove(userId);
          return p.copyWith(
            downvotes: p.downvotes + 1,
            upvotes: p.upvotedBy.contains(userId) ? p.upvotes - 1 : p.upvotes,
            upvotedBy: newUpvotedBy,
            downvotedBy: newDownvotedBy,
          );
        }
        return p;
      }).toList(),
    );

    // Call API in background
    await ForumService.votePost(
      postId: postId,
      userId: userId,
      voteType: 'down',
    );
  }

  Future<void> upvoteComment(String postId, String commentId) async {
    final userId = state.currentUserId;

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            comments: _updateCommentVote(
              post.comments,
              commentId,
              userId,
              true,
            ),
          );
        }
        return post;
      }).toList(),
    );

    // Call API in background
    await ForumService.voteComment(
      commentId: commentId,
      userId: userId,
      voteType: 'up',
    );
  }

  Future<void> downvoteComment(String postId, String commentId) async {
    final userId = state.currentUserId;

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            comments: _updateCommentVote(
              post.comments,
              commentId,
              userId,
              false,
            ),
          );
        }
        return post;
      }).toList(),
    );

    // Call API in background
    await ForumService.voteComment(
      commentId: commentId,
      userId: userId,
      voteType: 'down',
    );
  }

  List<Comment> _updateCommentVote(
    List<Comment> comments,
    String commentId,
    String userId,
    bool isUpvote,
  ) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        if (isUpvote) {
          if (comment.upvotedBy.contains(userId)) return comment;
          final newUpvotedBy = Set<String>.from(comment.upvotedBy)..add(userId);
          final newDownvotedBy = Set<String>.from(comment.downvotedBy)
            ..remove(userId);
          return comment.copyWith(
            upvotes: comment.upvotes + 1,
            downvotes: comment.downvotedBy.contains(userId)
                ? comment.downvotes - 1
                : comment.downvotes,
            upvotedBy: newUpvotedBy,
            downvotedBy: newDownvotedBy,
          );
        } else {
          if (comment.downvotedBy.contains(userId)) return comment;
          final newDownvotedBy = Set<String>.from(comment.downvotedBy)
            ..add(userId);
          final newUpvotedBy = Set<String>.from(comment.upvotedBy)
            ..remove(userId);
          return comment.copyWith(
            downvotes: comment.downvotes + 1,
            upvotes: comment.upvotedBy.contains(userId)
                ? comment.upvotes - 1
                : comment.upvotes,
            upvotedBy: newUpvotedBy,
            downvotedBy: newDownvotedBy,
          );
        }
      }
      // Check replies recursively
      if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _updateCommentVote(
            comment.replies,
            commentId,
            userId,
            isUpvote,
          ),
        );
      }
      return comment;
    }).toList();
  }

  Future<void> addReply(
    String postId,
    String parentCommentId,
    String text, {
    String? authorName,
    String? authorEmoji,
    String? authorId,
  }) async {
    if (text.trim().isEmpty) return;
    final newReply = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      createdAt: DateTime.now(),
      parentId: parentCommentId,
    );

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            comments: _addReplyToComment(
              post.comments,
              parentCommentId,
              newReply,
            ),
            commentCount: post.commentCount + 1,
          );
        }
        return post;
      }).toList(),
    );

    // Call API in background (using comment API since replies are just nested comments)
    await ForumService.addComment(
      postId: postId,
      authorId: authorId ?? state.currentUserId,
      authorName: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      content: text,
    );
  }

  List<Comment> _addReplyToComment(
    List<Comment> comments,
    String parentId,
    Comment reply,
  ) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        return comment.copyWith(replies: [...comment.replies, reply]);
      }
      if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _addReplyToComment(comment.replies, parentId, reply),
        );
      }
      return comment;
    }).toList();
  }

  Future<void> addComment(
    String postId,
    String text, {
    String? authorName,
    String? authorEmoji,
    String? authorId,
  }) async {
    if (text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      createdAt: DateTime.now(),
    );

    // Optimistic update
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(
            comments: [...p.comments, newComment],
            commentCount: p.commentCount + 1,
          );
        }
        return p;
      }).toList(),
    );

    // Call API in background
    await ForumService.addComment(
      postId: postId,
      authorId: authorId ?? state.currentUserId,
      authorName: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      content: text,
    );
  }

  Future<void> addPost(
    String title,
    String content,
    List<String> tags, {
    String? authorName,
    String? authorEmoji,
    String? authorId,
  }) async {
    // Optimistic local update
    final tempPost = ForumPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      author: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      upvotes: 1,
      downvotes: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      tags: tags,
    );
    state = state.copyWith(posts: [tempPost, ...state.posts]);

    // Call API
    final result = await ForumService.createPost(
      authorId: authorId ?? state.currentUserId,
      authorName: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      title: title,
      content: content,
      tags: tags,
    );

    // If we got a real post back, replace the temp one
    if (result != null) {
      final realPost = ForumPost.fromJson(result);
      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id == tempPost.id) return realPost;
          return p;
        }).toList(),
      );
    }
  }

  void toggleSavePost(String postId) {
    final newSaved = Set<String>.from(state.savedPostIds);
    if (newSaved.contains(postId)) {
      newSaved.remove(postId);
    } else {
      newSaved.add(postId);
    }
    state = state.copyWith(savedPostIds: newSaved);
    _saveSavedPostIds(); // Persist to SharedPreferences
  }

  bool isPostSaved(String postId) => state.savedPostIds.contains(postId);

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  ForumPost? getPostById(String id) {
    try {
      return state.posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final forumProvider = NotifierProvider<ForumController, ForumState>(
  ForumController.new,
);
