import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String author;
  final String avatarEmoji;
  final int upvotes;
  final int downvotes;
  final int commentCount;
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
    required this.createdAt,
    this.comments = const [],
    this.tags = const [],
    Set<String>? upvotedBy,
    Set<String>? downvotedBy,
  }) : upvotedBy = upvotedBy ?? {},
       downvotedBy = downvotedBy ?? {};

  ForumPost copyWith({
    int? upvotes,
    int? downvotes,
    int? commentCount,
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

  ForumState({
    required this.posts,
    this.sortBy = 'hot',
    this.currentUserId = 'currentUser',
    Set<String>? savedPostIds,
  }) : savedPostIds = savedPostIds ?? {};

  ForumState copyWith({
    List<ForumPost>? posts,
    String? sortBy,
    Set<String>? savedPostIds,
  }) {
    return ForumState(
      posts: posts ?? this.posts,
      sortBy: sortBy ?? this.sortBy,
      currentUserId: currentUserId,
      savedPostIds: savedPostIds ?? this.savedPostIds,
    );
  }
}

class ForumController extends Notifier<ForumState> {
  @override
  ForumState build() {
    return ForumState(
      posts: [
        ForumPost(
          id: '1',
          title: 'How do I manage state in Flutter?',
          content:
              'I am new to Flutter and confused about state management. Should I use Provider, Riverpod, or Bloc? What are the pros and cons of each?',
          author: 'FlutterNewbie',
          avatarEmoji: '🐣',
          upvotes: 42,
          downvotes: 3,
          commentCount: 3,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          tags: ['flutter', 'state-management', 'beginner'],
          comments: [
            Comment(
              id: 'c1',
              text: 'Great question! I recommend starting with Riverpod.',
              author: 'DevMaster',
              avatarEmoji: '🧑‍💻',
              upvotes: 15,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
            Comment(
              id: 'c2',
              text: 'Provider is simpler for beginners.',
              author: 'StudentPro',
              avatarEmoji: '👩‍🎓',
              upvotes: 8,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
            ),
            Comment(
              id: 'c3',
              text: 'Bloc is great for complex apps!',
              author: 'CodeBot',
              avatarEmoji: '🤖',
              upvotes: 5,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            ),
          ],
        ),
        ForumPost(
          id: '2',
          title: 'Tips for passing the Flutter certification?',
          content:
              'Has anyone taken the Flutter certification exam? Looking for study tips and resources.',
          author: 'CertSeeker',
          avatarEmoji: '📚',
          upvotes: 89,
          downvotes: 5,
          commentCount: 2,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          tags: ['certification', 'career', 'tips'],
          comments: [
            Comment(
              id: 'c4',
              text: 'Practice with the official codelabs!',
              author: 'CertifiedDev',
              avatarEmoji: '🏆',
              upvotes: 20,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
            ),
            Comment(
              id: 'c5',
              text: 'Focus on widget lifecycles.',
              author: 'FlutterPro',
              avatarEmoji: '💎',
              upvotes: 12,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            ),
          ],
        ),
        ForumPost(
          id: '3',
          title: 'Best practices for animations',
          content:
              'What are the best practices for creating smooth animations in Flutter? Any performance tips?',
          author: 'AnimationPro',
          avatarEmoji: '✨',
          upvotes: 127,
          downvotes: 8,
          commentCount: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['animations', 'performance', 'advanced'],
          comments: [
            Comment(
              id: 'c6',
              text: 'Use AnimatedBuilder for better performance!',
              author: 'PerfGuru',
              avatarEmoji: '⚡',
              upvotes: 25,
              downvotes: 0,
              createdAt: DateTime.now().subtract(const Duration(hours: 20)),
            ),
          ],
        ),
      ],
    );
  }

  void upvote(String postId) {
    final userId = state.currentUserId;
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
  }

  void downvote(String postId) {
    final userId = state.currentUserId;
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
  }

  void upvoteComment(String postId, String commentId) {
    final userId = state.currentUserId;
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
  }

  void downvoteComment(String postId, String commentId) {
    final userId = state.currentUserId;
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

  void addReply(
    String postId,
    String parentCommentId,
    String text, {
    String? authorName,
    String? authorEmoji,
  }) {
    if (text.trim().isEmpty) return;
    final newReply = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      createdAt: DateTime.now(),
      parentId: parentCommentId,
    );
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

  void addComment(
    String postId,
    String text, {
    String? authorName,
    String? authorEmoji,
  }) {
    if (text.trim().isEmpty) return;
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: authorName ?? 'You',
      avatarEmoji: authorEmoji ?? '🧑',
      createdAt: DateTime.now(),
    );
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
  }

  void addPost(
    String title,
    String content,
    List<String> tags, {
    String? authorName,
    String? authorEmoji,
  }) {
    final newPost = ForumPost(
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
    state = state.copyWith(posts: [newPost, ...state.posts]);
  }

  void toggleSavePost(String postId) {
    final newSaved = Set<String>.from(state.savedPostIds);
    if (newSaved.contains(postId)) {
      newSaved.remove(postId);
    } else {
      newSaved.add(postId);
    }
    state = state.copyWith(savedPostIds: newSaved);
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
