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
  final int votes;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.avatarEmoji,
    required this.votes,
    required this.createdAt,
  });
}

class ForumState {
  final List<ForumPost> posts;
  final String sortBy;
  final String currentUserId;

  ForumState({
    required this.posts,
    this.sortBy = 'hot',
    this.currentUserId = 'currentUser',
  });

  ForumState copyWith({List<ForumPost>? posts, String? sortBy}) {
    return ForumState(
      posts: posts ?? this.posts,
      sortBy: sortBy ?? this.sortBy,
      currentUserId: currentUserId,
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
              votes: 15,
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
            Comment(
              id: 'c2',
              text: 'Provider is simpler for beginners.',
              author: 'StudentPro',
              avatarEmoji: '👩‍🎓',
              votes: 8,
              createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
            ),
            Comment(
              id: 'c3',
              text: 'Bloc is great for complex apps!',
              author: 'CodeBot',
              avatarEmoji: '🤖',
              votes: 5,
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
              votes: 20,
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
            ),
            Comment(
              id: 'c5',
              text: 'Focus on widget lifecycles.',
              author: 'FlutterPro',
              avatarEmoji: '💎',
              votes: 12,
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
              votes: 25,
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

  void addComment(String postId, String text) {
    if (text.trim().isEmpty) return;
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: 'You',
      avatarEmoji: '🧑',
      votes: 0,
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

  void addPost(String title, String content, List<String> tags) {
    final newPost = ForumPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      author: 'You',
      avatarEmoji: '🧑',
      upvotes: 1,
      downvotes: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      tags: tags,
    );
    state = state.copyWith(posts: [newPost, ...state.posts]);
  }

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
