import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/instructor_state.dart';
import 'data/forum_state.dart';
import 'widgets/post_card.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Set student mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInstructorModeProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ForumPost> _filterPosts(List<ForumPost> posts) {
    if (_searchQuery.length < 3) return posts;
    final query = _searchQuery.toLowerCase();
    return posts.where((post) {
      return post.title.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query) ||
          post.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumProvider);
    final controller = ref.read(forumProvider.notifier);
    final userId = forumState.currentUserId;
    final filteredPosts = _filterPosts(forumState.posts);

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Community", style: AppTheme.headlineMedium),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search posts...',
                hintStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryCyan,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Sort Chips
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
          // Results Count (when searching)
          if (_searchQuery.length >= 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filteredPosts.length} result${filteredPosts.length == 1 ? '' : 's'} found',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ),
            ),
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          'No posts found',
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
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
