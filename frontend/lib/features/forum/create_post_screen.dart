import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/user_state.dart';
import '../../core/providers/instructor_state.dart';
import 'data/forum_state.dart';

// Provider to track if we're in instructor mode
final isInstructorModeProvider = StateProvider<bool>((ref) => false);

class CreatePostScreen extends ConsumerStatefulWidget {
  final bool fromInstructor;

  const CreatePostScreen({super.key, this.fromInstructor = false});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _submit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty)
      return;

    // Determine author based on context
    String authorName;
    String authorEmoji;

    if (widget.fromInstructor) {
      // Use instructor name
      final instructorState = ref.read(instructorStateProvider);
      authorName = instructorState.name;
      authorEmoji = '👨‍🏫';
    } else {
      // Use student name
      final userState = ref.read(userStateProvider);
      authorName = userState.profile.name;
      authorEmoji = '🎓';
    }

    ref
        .read(forumProvider.notifier)
        .addPost(
          _titleController.text,
          _contentController.text,
          _tags,
          authorName: authorName,
          authorEmoji: authorEmoji,
        );

    // Redirect based on where we came from
    if (widget.fromInstructor) {
      context.go('/instructor/forum');
    } else {
      context.go('/forum');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInstructor = widget.fromInstructor;
    final accentColor = isInstructor ? Colors.orange : AppTheme.primaryCyan;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Create Post", style: AppTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.fromInstructor) {
              context.go('/instructor/forum');
            } else {
              context.go('/forum');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              "Post",
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Author Preview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isInstructor ? '👨‍🏫' : '🎓',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isInstructor
                                ? ref.watch(instructorStateProvider).name
                                : ref.watch(userStateProvider).profile.name,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isInstructor) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INSTRUCTOR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Posting as ${isInstructor ? "Instructor" : "Student"}',
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: AppTheme.headlineMedium.copyWith(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                  ),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  Text(
                    "Tags (max 5)",
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Add tag...",
                            hintStyle: TextStyle(color: AppTheme.textGrey),
                            filled: true,
                            fillColor: AppTheme.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTag,
                        icon: Icon(Icons.add_circle, color: accentColor),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: accentColor.withOpacity(0.2),
                              labelStyle: TextStyle(color: accentColor),
                              deleteIconColor: accentColor,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      style: AppTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(color: AppTheme.textGrey),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
