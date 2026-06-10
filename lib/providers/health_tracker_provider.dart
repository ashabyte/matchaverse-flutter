import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/intake_record.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class HealthTrackerProvider extends ChangeNotifier {
  List<IntakeRecord> _todayRecords = [];
  List<IntakeRecord> _monthlyRecords = [];
  Map<String, dynamic> _yearlyStats = {};
  bool _isLoading = false;

  // Caffeine limits (mg)
  static const double dailyCaffeineLimit = 400.0;   // FDA recommendation
  static const double safeSingleDose = 200.0;

  // Matcha caffeine per gram (approximate)
  static const double caffeinePerGram = 35.0;       // ~35mg per gram of matcha powder

  List<IntakeRecord> get todayRecords => _todayRecords;
  List<IntakeRecord> get monthlyRecords => _monthlyRecords;
  Map<String, dynamic> get yearlyStats => _yearlyStats;
  bool get isLoading => _isLoading;

  double get todayTotalCaffeine {
    return _todayRecords.fold(0.0, (sum, r) => sum + r.caffeineAmount);
  }

  double get todayTotalGrams {
    return _todayRecords.fold(0.0, (sum, r) => sum + r.gramsConsumed);
  }

  double get caffeinePercent => (todayTotalCaffeine / dailyCaffeineLimit).clamp(0.0, 1.0);

  bool get isOverLimit => todayTotalCaffeine >= dailyCaffeineLimit;
  bool get isNearLimit => todayTotalCaffeine >= dailyCaffeineLimit * 0.8;

  Future<void> fetchTodayRecords(String userId, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _todayRecords = await ApiService.getIntakeRecords(userId, token, date: today);
    } catch (e) {
      debugPrint('Error fetching today records: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMonthlyRecords(String userId, String token, int year, int month) async {
    _isLoading = true;
    notifyListeners();
    try {
      _monthlyRecords = await ApiService.getIntakeRecords(
        userId, token,
        year: year, month: month,
      );
    } catch (e) {
      debugPrint('Error fetching monthly records: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchYearlyStats(String userId, String token, int year) async {
    _isLoading = true;
    notifyListeners();
    try {
      _yearlyStats = await ApiService.getYearlyStats(userId, token, year);
    } catch (e) {
      debugPrint('Error fetching yearly stats: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addIntakeRecord(IntakeRecord record, String token) async {
    try {
      final created = await ApiService.createIntakeRecord(record, token);
      _todayRecords.insert(0, created);
      notifyListeners();

      // Check caffeine limit and send notification if needed
      _checkCaffeineLimit();

      return true;
    } catch (e) {
      debugPrint('Error adding intake: $e');
      return false;
    }
  }

  Future<bool> updateIntakeRecord(IntakeRecord record, String token) async {
    try {
      await ApiService.updateIntakeRecord(record, token);
      final idx = _todayRecords.indexWhere((r) => r.id == record.id);
      if (idx != -1) {
        _todayRecords[idx] = record;
        notifyListeners();
        _checkCaffeineLimit();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteIntakeRecord(String recordId, String token) async {
    try {
      await ApiService.deleteIntakeRecord(recordId, token);
      _todayRecords.removeWhere((r) => r.id == recordId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _checkCaffeineLimit() {
    if (isOverLimit) {
      NotificationService.showCaffeineAlert(
        title: '⚠️ Batas Kafein Tercapai!',
        body: 'Konsumsi kafein harian kamu sudah ${todayTotalCaffeine.toStringAsFixed(0)}mg. '
            'Batas aman adalah ${dailyCaffeineLimit.toStringAsFixed(0)}mg per hari.',
      );
    } else if (isNearLimit) {
      NotificationService.showCaffeineAlert(
        title: '🍵 Hampir di Batas Kafein',
        body: 'Sudah ${todayTotalCaffeine.toStringAsFixed(0)}mg dari ${dailyCaffeineLimit.toStringAsFixed(0)}mg. '
            'Pertimbangkan untuk mengurangi konsumsi matcha hari ini.',
      );
    }
  }

  // Get monthly summary for chart
  Map<int, double> get monthlySummaryByDay {
    final Map<int, double> summary = {};
    for (final record in _monthlyRecords) {
      final day = record.consumedAt.day;
      summary[day] = (summary[day] ?? 0) + record.caffeineAmount;
    }
    return summary;
  }

  // Yearly chart data
  Map<int, int> get yearlyConsumptionByMonth {
    final Map<int, int> monthly = {for (var i = 1; i <= 12; i++) i: 0};
    for (final record in _monthlyRecords) {
      final month = record.consumedAt.month;
      monthly[month] = (monthly[month] ?? 0) + 1;
    }
    return monthly;
  }
}
