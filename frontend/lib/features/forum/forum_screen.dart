import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/instructor_state.dart';
import '../../core/providers/user_state.dart';
import 'data/forum_state.dart';

class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  String _selectedTag = 'All';

  final List<String> _filterTags = [
    'All',
    'flutter',
    'dart',
    'state-management',
    'beginner',
    'certification',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Set student mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInstructorModeProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forumState = ref.watch(forumProvider);
    final userState = ref.watch(userStateProvider);
    final userName = userState.profile.name;

    List<ForumPost> filteredPosts = forumState.posts;

    // Filter by search
    if (_searchQuery.length >= 2) {
      filteredPosts = filteredPosts
          .where(
            (p) =>
                p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.content.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Filter by tag
    if (_selectedTag != 'All') {
      filteredPosts = filteredPosts
          .where((p) => p.tags.contains(_selectedTag))
          .toList();
    }

    // My Posts
    final myPosts = filteredPosts.where((p) => p.author == userName).toList();

    // Saved Posts
    final savedPosts = forumState.posts
        .where((p) => forumState.savedPostIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Community Forum", style: AppTheme.headlineMedium),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppTheme.primaryCyan),
            ),
            onPressed: () => context.push('/forum/create'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryCyan,
          labelColor: AppTheme.primaryCyan,
          unselectedLabelColor: AppTheme.textGrey,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All Posts'),
            Tab(text: 'My Posts (${myPosts.length})'),
            const Tab(text: 'Trending'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark, size: 16),
                  const SizedBox(width: 4),
                  Text('Saved (${savedPosts.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search posts, questions, topics...',
                hintStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryCyan,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 18,
                        ),
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
              ),
            ),
          ),

          // Tag Filter
          SizedBox(
            height: 36,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filterTags.length,
              itemBuilder: (context, index) {
                final tag = _filterTags[index];
                final isSelected = tag == _selectedTag;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTag = tag),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryCyan
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryCyan
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag == 'All' ? '🔥 All' : '#$tag',
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Posts List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(filteredPosts),
                _buildPostsList(myPosts),
                _buildPostsList(
                  [...filteredPosts]
                    ..sort((a, b) => b.upvotes.compareTo(a.upvotes)),
                ),
                _buildPostsList(savedPosts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<ForumPost> posts) {
    final forumState = ref.watch(forumProvider);

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 60, color: AppTheme.textGrey),
            const SizedBox(height: 16),
            Text('No posts found', style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.push('/forum/create'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create First Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isSaved = forumState.savedPostIds.contains(post.id);
        final hasUpvoted = post.upvotedBy.contains(forumState.currentUserId);
        final hasDownvoted = post.downvotedBy.contains(
          forumState.currentUserId,
        );

        return GestureDetector(
          onTap: () => context.push('/forum/${post.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            post.avatarEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatTime(post.createdAt),
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Save Button
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(forumProvider.notifier)
                              .toggleSavePost(post.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSaved
                                ? AppTheme.primaryCyan.withOpacity(0.2)
                                : AppTheme.bgBlack.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved
                                ? AppTheme.primaryCyan
                                : AppTheme.textGrey,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title & Content Preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    post.title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      post.content,
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Tags
                if (post.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: post.tags.map((tag) {
                        final tagColor = _getTagColor(tag);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tagColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Stats Bar with Clickable Votes
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgBlack.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Upvote Button
                      GestureDetector(
                        onTap: () {
                          if (!hasUpvoted) {
                            ref.read(forumProvider.notifier).upvote(post.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasUpvoted
                                ? Colors.green.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasUpvoted
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 16,
                                color: hasUpvoted
                                    ? Colors.green
                                    : AppTheme.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.upvotes}',
                                style: TextStyle(
                                  color: hasUpvoted
                                      ? Colors.green
                                      : AppTheme.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Downvote Button
                      GestureDetector(
                        onTap: () {
                          if (!hasDownvoted) {
                            ref.read(forumProvider.notifier).downvote(post.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: hasDownvoted
                                ? Colors.red.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasDownvoted
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                size: 16,
                                color: hasDownvoted
                                    ? Colors.red
                                    : AppTheme.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.downvotes}',
                                style: TextStyle(
                                  color: hasDownvoted
                                      ? Colors.red
                                      : AppTheme.textGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.chat_bubble_rounded,
                        size: 16,
                        color: AppTheme.primaryCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          color: AppTheme.primaryCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: AppTheme.primaryCyan,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.viewCount}',
                              style: const TextStyle(
                                color: AppTheme.primaryCyan,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'flutter':
        return Colors.blue;
      case 'dart':
        return Colors.teal;
      case 'state-management':
        return Colors.purple;
      case 'beginner':
        return Colors.green;
      case 'certification':
        return Colors.amber;
      case 'tips':
        return Colors.pink;
      case 'career':
        return Colors.indigo;
      default:
        return AppTheme.primaryCyan;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
