import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'data/forum_state.dart';
import 'widgets/post_card.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumState = ref.watch(forumProvider);
    final controller = ref.read(forumProvider.notifier);
    final userId = forumState.currentUserId;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Community", style: AppTheme.headlineMedium),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Hot', 'New', 'Top'].map((sort) {
                final isSelected =
                    forumState.sortBy.toLowerCase() == sort.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sort),
                    selected: isSelected,
                    onSelected: (_) => controller.setSortBy(sort.toLowerCase()),
                    selectedColor: AppTheme.primaryCyan,
                    backgroundColor: AppTheme.cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: forumState.posts.length,
              itemBuilder: (context, index) {
                final post = forumState.posts[index];
                return PostCard(
                      post: post,
                      hasUpvoted: post.upvotedBy.contains(userId),
                      hasDownvoted: post.downvotedBy.contains(userId),
                      onTap: () => context.go('/forum/${post.id}'),
                      onUpvote: () => controller.upvote(post.id),
                      onDownvote: () => controller.downvote(post.id),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/forum/create'),
        backgroundColor: AppTheme.accentPurple,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
