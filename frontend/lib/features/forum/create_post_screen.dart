import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'data/forum_state.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

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

    ref
        .read(forumProvider.notifier)
        .addPost(_titleController.text, _contentController.text, _tags);

    context.go('/forum');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Create Post", style: AppTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/forum'),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              "Post",
              style: TextStyle(
                color: AppTheme.primaryCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryCyan,
                  ),
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
                        backgroundColor: AppTheme.accentPurple.withOpacity(0.2),
                        labelStyle: TextStyle(color: AppTheme.accentPurple),
                        deleteIconColor: AppTheme.accentPurple,
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
    );
  }
}
