import 'package:flutter/foundation.dart';
import '../models/mission.dart';
import '../models/badge_model.dart';
import '../models/leaderboard_entry.dart';
import '../services/api_service.dart';

class GamificationProvider extends ChangeNotifier {
  List<Mission> _dailyMissions = [];
  List<Mission> _weeklyMissions = [];
  List<BadgeModel> _badges = [];
  List<LeaderboardEntry> _leaderboard = [];
  int _userPoints = 0;
  int _userRank = 0;
  bool _isLoading = false;

  List<Mission> get dailyMissions => _dailyMissions;
  List<Mission> get weeklyMissions => _weeklyMissions;
  List<BadgeModel> get badges => _badges;
  List<BadgeModel> get earnedBadges => _badges.where((b) => b.isEarned).toList();
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  int get userPoints => _userPoints;
  int get userRank => _userRank;
  bool get isLoading => _isLoading;

  int get completedDailyCount => _dailyMissions.where((m) => m.isCompleted).length;
  int get completedWeeklyCount => _weeklyMissions.where((m) => m.isCompleted).length;

  Future<void> fetchMissions(String userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _dailyMissions = await ApiService.getMissions(userId, token, type: 'daily');
      _weeklyMissions = await ApiService.getMissions(userId, token, type: 'weekly');
    } catch (e) {
      debugPrint('Error fetching missions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBadges(String userId, String token) async {
    try {
      _badges = await ApiService.getBadges(userId, token);
    } catch (e) {
      debugPrint('Error fetching badges: $e');
    }
    notifyListeners();
  }

  Future<void> fetchLeaderboard(String token) async {
    try {
      _leaderboard = await ApiService.getLeaderboard(token);
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    }
    notifyListeners();
  }

  Future<void> fetchUserStats(String userId, String token) async {
    try {
      final stats = await ApiService.getUserGameStats(userId, token);
      _userPoints = (stats['points'] ?? 0) as int;
      _userRank = (stats['rank'] ?? 0) as int;
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
    }
    notifyListeners();
  }

  Future<bool> completeMission(String missionId, String userId, String token) async {
    try {
      final result = await ApiService.completeMission(missionId, userId, token);
      // Update mission state lokal
      final dailyIdx = _dailyMissions.indexWhere((m) => m.id == missionId);
      if (dailyIdx != -1) {
        _dailyMissions[dailyIdx] = _dailyMissions[dailyIdx].copyWith(isCompleted: true);
      }
      final weeklyIdx = _weeklyMissions.indexWhere((m) => m.id == missionId);
      if (weeklyIdx != -1) {
        _weeklyMissions[weeklyIdx] = _weeklyMissions[weeklyIdx].copyWith(isCompleted: true);
      }
      // ✅ FIX: cast ke int karena JSON decode menghasilkan num
      _userPoints += (result['pointsEarned'] ?? 0) as int;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing mission: $e');
      return false;
    }
  }
}