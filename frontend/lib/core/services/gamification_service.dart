import '../services/api_service.dart';

class GamificationService {
  /// Fetches all available achievements.
  static Future<List<Map<String, dynamic>>> fetchAchievements() async {
    try {
      final response = await ApiService.get('/api/achievements');
      if (response['success'] == true && response['achievements'] != null) {
        return List<Map<String, dynamic>>.from(response['achievements']);
      }
      return [];
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  /// Fetches achievements unlocked by the current user.
  static Future<List<Map<String, dynamic>>> fetchUserAchievements() async {
    try {
      final response = await ApiService.get('/api/user/achievements');
      if (response['success'] == true && response['achievements'] != null) {
        return List<Map<String, dynamic>>.from(response['achievements']);
      }
      return [];
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  /// Fetches statistics for the current user.
  static Future<Map<String, dynamic>?> fetchUserStats() async {
    try {
      final response = await ApiService.get('/api/user/stats');
      if (response['success'] == true && response['stats'] != null) {
        return Map<String, dynamic>.from(response['stats']);
      }
      return null;
    } catch (e) {
      print('Error fetching user stats: $e');
      return null;
    }
  }

  /// Fetches the leaderboard data.
  static Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    try {
      final response = await ApiService.get('/api/leaderboard');
      if (response['success'] == true && response['leaderboard'] != null) {
        return List<Map<String, dynamic>>.from(response['leaderboard']);
      }
      return [];
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Completes a battle and updates stats.
  static Future<bool> completeBattle(String userId, bool win, int xp) async {
    try {
      final response = await ApiService.post('/api/battles/complete', {
        'userId': userId,
        'win': win,
        'xp': xp,
      });
      return response['success'] == true;
    } catch (e) {
      print('Error completing battle: $e');
      return false;
    }
  }
}
