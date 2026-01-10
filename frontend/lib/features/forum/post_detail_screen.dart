import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'data/forum_state.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyingToCommentId;
  String? _replyingToAuthor;

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    if (_replyingToCommentId != null) {
      ref
          .read(forumProvider.notifier)
          .addReply(
            widget.postId,
            _replyingToCommentId!,
            _commentController.text,
          );
    } else {
      ref
          .read(forumProvider.notifier)
          .addComment(widget.postId, _commentController.text);
    }

    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthor = null;
    });
  }

  void _startReply(String commentId, String author) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToAuthor = author;
    });
    // Focus the text field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumProvider);
    final controller = ref.read(forumProvider.notifier);
    final post = controller.getPostById(widget.postId);

    if (post == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgBlack,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text("Post not found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final userId = forumState.currentUserId;
    final karma = post.upvotes - post.downvotes;
    final hasUpvoted = post.upvotedBy.contains(userId);
    final hasDownvoted = post.downvotedBy.contains(userId);

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(post.avatarEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Posted 2h ago',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: AppTheme.headlineMedium,
            ).animate().fadeIn(delay: 100.ms),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: post.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppTheme.accentPurple,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              post.content,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white70,
                height: 1.6,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.upvote(post.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: hasUpvoted
                          ? AppTheme.primaryCyan.withOpacity(0.2)
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasUpvoted
                            ? AppTheme.primaryCyan
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 18,
                          color: hasUpvoted
                              ? AppTheme.primaryCyan
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          karma.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: hasUpvoted
                                ? AppTheme.primaryCyan
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.downvote(post.id),
                          child: Icon(
                            Icons.arrow_downward,
                            size: 18,
                            color: hasDownvoted ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('${post.comments.length}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              'Comments (${post.comments.length})',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 16),
            ...post.comments.asMap().entries.map((entry) {
              final index = entry.key;
              final comment = entry.value;
              return _buildCommentWidget(comment, controller, userId, index, 0);
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToAuthor != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Replying to @$_replyingToAuthor',
                      style: TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _replyingToAuthor != null
                          ? 'Write a reply...'
                          : 'Add a comment...',
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                  onPressed: _submitComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget(
    Comment comment,
    ForumController controller,
    String userId,
    int index,
    int depth,
  ) {
    final hasUpvoted = comment.upvotedBy.contains(userId);
    final hasDownvoted = comment.downvotedBy.contains(userId);
    final karma = comment.upvotes - comment.downvotes;

    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: depth > 0
                  ? AppTheme.cardColor.withOpacity(0.5)
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: depth > 0
                  ? Border(
                      left: BorderSide(
                        color: AppTheme.primaryCyan.withOpacity(0.3),
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.avatarEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.author,
                      style: TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${index + 1}h ago',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          controller.upvoteComment(widget.postId, comment.id),
                      child: Icon(
                        Icons.arrow_upward,
                        size: 14,
                        color: hasUpvoted ? AppTheme.primaryCyan : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      karma.toString(),
                      style: TextStyle(
                        color: hasUpvoted
                            ? AppTheme.primaryCyan
                            : hasDownvoted
                            ? Colors.red
                            : AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          controller.downvoteComment(widget.postId, comment.id),
                      child: Icon(
                        Icons.arrow_downward,
                        size: 14,
                        color: hasDownvoted ? Colors.red : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _startReply(comment.id, comment.author),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: AppTheme.primaryCyan,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (300 + index * 100).ms),
          // Render replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.asMap().entries.map((entry) {
              return _buildCommentWidget(
                entry.value,
                controller,
                userId,
                entry.key,
                depth + 1,
              );
            }),
        ],
      ),
    );
  }
}
