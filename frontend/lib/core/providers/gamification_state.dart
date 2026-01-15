import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gamification_service.dart';

// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String requirement;
  final int xpReward;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requirement,
    required this.xpReward,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🏆',
      requirement: json['requirement'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      category: json['category'] ?? '',
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      requirement: requirement,
      xpReward: xpReward,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

// User statistics model
class UserStats {
  final int totalXp;
  final int level;
  final int battlesWon;
  final int battlesPlayed;
  final int coursesCompleted;
  final int coursesEnrolled;
  final int currentStreak;
  final int longestStreak;
  final int globalRank;
  final int forumPosts;
  final int forumComments;

  UserStats({
    this.totalXp = 0,
    this.level = 1,
    this.battlesWon = 0,
    this.battlesPlayed = 0,
    this.coursesCompleted = 0,
    this.coursesEnrolled = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.globalRank = 42,
    this.forumPosts = 0,
    this.forumComments = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      battlesWon: json['battlesWon'] ?? 0,
      battlesPlayed: json['battlesPlayed'] ?? 0,
      coursesCompleted: json['coursesCompleted'] ?? 0,
      coursesEnrolled: json['coursesEnrolled'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      globalRank: json['globalRank'] ?? 42,
      forumPosts: json['forumPosts'] ?? 0,
      forumComments: json['forumComments'] ?? 0,
    );
  }
}

// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String avatarEmoji;
  final int totalXp;
  final int level;
  final int battlesWon;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.avatarEmoji,
    required this.totalXp,
    required this.level,
    required this.battlesWon,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      avatarEmoji: json['avatarEmoji'] ?? '🧑',
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      battlesWon: json['battlesWon'] ?? 0,
    );
  }
}

// Gamification state
class GamificationState {
  final List<Achievement> achievements;
  final UserStats userStats;
  final List<LeaderboardEntry> leaderboard;
  final bool isLoading;
  final String? error;

  GamificationState({
    this.achievements = const [],
    UserStats? userStats,
    this.leaderboard = const [],
    this.isLoading = false,
    this.error,
  }) : userStats = userStats ?? UserStats();

  GamificationState copyWith({
    List<Achievement>? achievements,
    UserStats? userStats,
    List<LeaderboardEntry>? leaderboard,
    bool? isLoading,
    String? error,
  }) {
    return GamificationState(
      achievements: achievements ?? this.achievements,
      userStats: userStats ?? this.userStats,
      leaderboard: leaderboard ?? this.leaderboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Gamification controller
class GamificationController extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    // Initialize by fetching data
    _loadAllData();
    return GamificationState(isLoading: true);
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      fetchAchievements(),
      fetchUserStats(),
      fetchLeaderboard(),
    ]);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadAllData();
  }

  Future<void> fetchAchievements() async {
    try {
      // Fetch all achievements
      final achievementsData = await GamificationService.fetchAchievements();

      // Fetch user's unlocked achievements
      final userAchievementsData =
          await GamificationService.fetchUserAchievements();
      final unlockedIds = userAchievementsData
          .map((a) => a['achievementId'] as String)
          .toSet();

      final achievements = achievementsData.map((data) {
        final id = data['id'] as String;
        final isUnlocked = unlockedIds.contains(id);
        return Achievement.fromJson(data, isUnlocked: isUnlocked);
      }).toList();

      state = state.copyWith(achievements: achievements, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchUserStats() async {
    try {
      final statsData = await GamificationService.fetchUserStats();
      if (statsData != null) {
        state = state.copyWith(userStats: UserStats.fromJson(statsData));
      }
    } catch (e) {
      // Keep default stats on error
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      final leaderboardData = await GamificationService.fetchLeaderboard();
      final leaderboard = leaderboardData
          .map((data) => LeaderboardEntry.fromJson(data))
          .toList();
      state = state.copyWith(leaderboard: leaderboard);
    } catch (e) {
      // Keep empty leaderboard on error
    }
  }
}

// Provider
final gamificationProvider =
    NotifierProvider<GamificationController, GamificationState>(
      GamificationController.new,
    );
