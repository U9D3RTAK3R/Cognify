import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/user_state.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late String _selectedEmoji;

  final List<String> _avatarOptions = [
    '🥷',
    '🧑‍💻',
    '👨‍🎓',
    '🦄',
    '🐱',
    '🤖',
    '👾',
    '🎮',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userStateProvider).profile;
    _nameController = TextEditingController(text: profile.name);
    _usernameController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _selectedEmoji = profile.avatarEmoji;
  }

  void _saveProfile() {
    ref
        .read(userStateProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          avatarEmoji: _selectedEmoji,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated!'),
        backgroundColor: AppTheme.primaryCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Selection
            GestureDetector(
              onTap: () => _showAvatarPicker(),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryCyan, AppTheme.accentPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bgBlack, width: 3),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to change avatar',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),

            const SizedBox(height: 32),

            // Form Fields
            _buildTextField(
              'Display Name',
              _nameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Username',
              _usernameController,
              Icons.alternate_email,
              prefix: '@',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Bio',
              _bioController,
              Icons.info_outline,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? prefix,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textGrey),
          prefixIcon: Icon(icon, color: AppTheme.primaryCyan),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Avatar', style: AppTheme.headlineMedium),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _avatarOptions.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmoji = emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.primaryCyan.withOpacity(0.2)
                          : AppTheme.bgBlack,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryCyan
                            : Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
