import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User Profile
class UserProfile {
  final String name;
  final String username;
  final String bio;
  final String avatarEmoji;

  const UserProfile({
    this.name = 'Cyber Ninja',
    this.username = 'cyberninja42',
    this.bio = 'Learning every day!',
    this.avatarEmoji = '🥷',
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? avatarEmoji,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}

// App Settings
class AppSettings {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool soundEffects;
  final bool hapticFeedback;

  const AppSettings({
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.soundEffects = true,
    this.hapticFeedback = true,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEffects,
    bool? hapticFeedback,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEffects: soundEffects ?? this.soundEffects,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

// User Stats
class UserStats {
  final int level;
  final int currentXp;
  final int maxXp;
  final int battlesWon;
  final int courses;
  final int streak;
  final int globalRank;

  const UserStats({
    this.level = 5,
    this.currentXp = 350,
    this.maxXp = 1000,
    this.battlesWon = 12,
    this.courses = 3,
    this.streak = 7,
    this.globalRank = 42,
  });

  UserStats copyWith({
    int? level,
    int? currentXp,
    int? maxXp,
    int? battlesWon,
    int? courses,
    int? streak,
    int? globalRank,
  }) {
    return UserStats(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      maxXp: maxXp ?? this.maxXp,
      battlesWon: battlesWon ?? this.battlesWon,
      courses: courses ?? this.courses,
      streak: streak ?? this.streak,
      globalRank: globalRank ?? this.globalRank,
    );
  }
}

// Notification Item
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.isUnread = true,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      icon: icon,
      color: color,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

// Complete User State
class UserState {
  final UserProfile profile;
  final AppSettings settings;
  final UserStats stats;
  final List<NotificationItem> notifications;

  const UserState({
    this.profile = const UserProfile(),
    this.settings = const AppSettings(),
    this.stats = const UserStats(),
    this.notifications = const [],
  });

  UserState copyWith({
    UserProfile? profile,
    AppSettings? settings,
    UserStats? stats,
    List<NotificationItem>? notifications,
  }) {
    return UserState(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      notifications: notifications ?? this.notifications,
    );
  }
}

// User State Notifier
class UserStateNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    _loadSettings();
    return UserState(
      notifications: [
        NotificationItem(
          id: '1',
          title: 'Battle Challenge!',
          body: 'Cyber Ninja challenges you to a duel.',
          time: '2m ago',
          icon: Icons.bolt,
          color: const Color(0xFFB388FF),
          isUnread: true,
        ),
        NotificationItem(
          id: '2',
          title: 'Level Up!',
          body: 'You reached Level 5. Keep it up!',
          time: '2h ago',
          icon: Icons.arrow_upward,
          color: const Color(0xFF00E5CC),
          isUnread: true,
        ),
        NotificationItem(
          id: '3',
          title: 'New Course Available',
          body: 'Mastering Flutter Animations is now live.',
          time: '1d ago',
          icon: Icons.school,
          color: Colors.orange,
          isUnread: false,
        ),
        NotificationItem(
          id: '4',
          title: 'Streak Saver Used',
          body: 'You missed a day, but your streak is safe.',
          time: '2d ago',
          icon: Icons.local_fire_department,
          color: Colors.red,
          isUnread: false,
        ),
      ],
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    final soundEffects = prefs.getBool('soundEffects') ?? true;
    final hapticFeedback = prefs.getBool('hapticFeedback') ?? true;

    state = state.copyWith(
      settings: AppSettings(
        isDarkMode: isDarkMode,
        notificationsEnabled: notificationsEnabled,
        soundEffects: soundEffects,
        hapticFeedback: hapticFeedback,
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state.settings.isDarkMode);
    await prefs.setBool(
      'notificationsEnabled',
      state.settings.notificationsEnabled,
    );
    await prefs.setBool('soundEffects', state.settings.soundEffects);
    await prefs.setBool('hapticFeedback', state.settings.hapticFeedback);
  }

  // Profile Methods
  void updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarEmoji,
  }) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        name: name,
        username: username,
        bio: bio,
        avatarEmoji: avatarEmoji,
      ),
    );
  }

  // Settings Methods
  void setDarkMode(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(isDarkMode: value),
    );
    _saveSettings();
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(notificationsEnabled: value),
    );
    _saveSettings();
  }

  void setSoundEffects(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(soundEffects: value),
    );
    _saveSettings();
  }

  void setHapticFeedback(bool value) {
    state = state.copyWith(
      settings: state.settings.copyWith(hapticFeedback: value),
    );
    _saveSettings();
  }

  // Stats Methods
  void addXp(int xp) {
    var newXp = state.stats.currentXp + xp;
    var newLevel = state.stats.level;
    var newMaxXp = state.stats.maxXp;

    while (newXp >= newMaxXp) {
      newXp -= newMaxXp;
      newLevel++;
      newMaxXp = (newMaxXp * 1.2).toInt();
    }

    state = state.copyWith(
      stats: state.stats.copyWith(
        currentXp: newXp,
        level: newLevel,
        maxXp: newMaxXp,
      ),
    );
  }

  void incrementBattlesWon() {
    state = state.copyWith(
      stats: state.stats.copyWith(battlesWon: state.stats.battlesWon + 1),
    );
  }

  // Notification Methods
  void clearAllNotifications() {
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.copyWith(isUnread: false))
          .toList(),
    );
  }

  void markNotificationRead(String id) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isUnread: false);
        return n;
      }).toList(),
    );
  }

  int get unreadCount => state.notifications.where((n) => n.isUnread).length;
}

// Providers
final userStateProvider = NotifierProvider<UserStateNotifier, UserState>(
  UserStateNotifier.new,
);
