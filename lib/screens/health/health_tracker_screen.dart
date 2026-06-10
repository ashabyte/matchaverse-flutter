import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/health_tracker_provider.dart';
import '../../providers/auth_provider.dart';

class HealthTrackerScreen extends StatelessWidget {
  const HealthTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Health Tracker'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.monthlyRecap),
            icon: const Icon(Icons.bar_chart_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.yearlyWrapped),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.dailyIntake),
        backgroundColor: AppTheme.matchaPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Catat Konsumsi', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<HealthTrackerProvider>(
        builder: (context, tracker, _) {
          return RefreshIndicator(
            onRefresh: () {
              final auth = context.read<AuthProvider>();
              return tracker.fetchTodayRecords(auth.user!.uid, auth.authToken!);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCaffeineSummary(tracker),
                  const SizedBox(height: 20),
                  _buildQuickStats(tracker),
                  const SizedBox(height: 20),
                  const Text('Riwayat Hari Ini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 12),
                  if (tracker.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (tracker.todayRecords.isEmpty)
                    _buildEmptyState()
                  else
                    ...tracker.todayRecords.map((r) => _buildRecordCard(context, r, tracker)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaffeineSummary(HealthTrackerProvider tracker) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tracker.isOverLimit
              ? [Colors.red.shade400, Colors.red.shade700]
              : tracker.isNearLimit
                  ? [Colors.orange.shade400, Colors.orange.shade700]
                  : [AppTheme.matchaPrimary, AppTheme.matchaDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kafein Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tracker.isOverLimit ? '⚠️ Melebihi Batas!' : tracker.isNearLimit ? '⚠️ Hampir Batas' : '✅ Aman',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${tracker.todayTotalCaffeine.toStringAsFixed(0)} mg',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
          ),
          Text('dari ${HealthTrackerProvider.dailyCaffeineLimit.toStringAsFixed(0)} mg batas aman harian',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: tracker.caffeinePercent,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(tracker.caffeinePercent * 100).toStringAsFixed(0)}% dari batas harian',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildQuickStats(HealthTrackerProvider tracker) {
    return Row(
      children: [
        _statCard('☕ Sesi', '${tracker.todayRecords.length}x', Colors.brown),
        const SizedBox(width: 12),
        _statCard('🌿 Total', '${tracker.todayTotalGrams.toStringAsFixed(1)}g', AppTheme.matchaPrimary),
        const SizedBox(width: 12),
        _statCard('⚡ Kafein', '${tracker.todayTotalCaffeine.toStringAsFixed(0)}mg', Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Text('🍵', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Belum ada konsumsi hari ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          SizedBox(height: 4),
          Text('Tap tombol + untuk catat konsumsi matcha kamu', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, dynamic r, HealthTrackerProvider tracker) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.matchaAccent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.matchaLight, borderRadius: BorderRadius.circular(10)),
                child: const Text('🍵', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.matchaType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    Text('${r.gramsConsumed}g • ${r.caffeineAmount.toStringAsFixed(0)}mg kafein',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                    if (r.notes.isNotEmpty)
                      Text(r.notes, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () async {
                  await tracker.deleteIntakeRecord(r.id, auth.authToken!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}