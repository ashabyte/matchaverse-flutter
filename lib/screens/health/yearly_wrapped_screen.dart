import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_tracker_provider.dart';

class YearlyWrappedScreen extends StatefulWidget {
  const YearlyWrappedScreen({super.key});

  @override
  State<YearlyWrappedScreen> createState() => _YearlyWrappedScreenState();
}

class _YearlyWrappedScreenState extends State<YearlyWrappedScreen> {
  late int _selectedYear;

  final List<String> _monthShort = [
    'Jan','Feb','Mar','Apr','Mei','Jun',
    'Jul','Agu','Sep','Okt','Nov','Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _fetchData();
  }

  void _fetchData() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<HealthTrackerProvider>().fetchYearlyStats(
        auth.user!.uid, auth.authToken ?? '', _selectedYear,
      );
    }
  }

  void _changeYear(int delta) {
    setState(() => _selectedYear += delta);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Rekap Tahunan')),
      body: Consumer<HealthTrackerProvider>(
        builder: (context, provider, _) {
          final stats     = provider.yearlyStats;
          final byMonth   = provider.yearlyConsumptionByMonth;

          final totalCaffeine  = (stats['total_caffeine']  as num?)?.toDouble() ?? 0.0;
          final totalGrams     = (stats['total_grams']     as num?)?.toDouble() ?? 0.0;
          final totalSessions  = (stats['total_sessions']  as num?)?.toInt()    ?? 0;
          final activeDays     = (stats['active_days']     as num?)?.toInt()    ?? 0;
          final favType        = stats['favorite_type']    as String? ?? '-';
          final bestMonth      = (stats['best_month']      as num?)?.toInt();
          final avgDaily       = activeDays > 0 ? totalCaffeine / activeDays : 0.0;

          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildYearSelector(),
                      const SizedBox(height: 16),
                      _buildHeroCard(
                        totalSessions: totalSessions,
                        totalGrams: totalGrams,
                        activeDays: activeDays,
                      ),
                      const SizedBox(height: 16),
                      _buildStatGrid(
                        totalCaffeine: totalCaffeine,
                        avgDaily: avgDaily,
                        favType: favType,
                        bestMonth: bestMonth,
                      ),
                      const SizedBox(height: 20),
                      _buildBarChart(byMonth),
                      const SizedBox(height: 20),
                      _buildMonthlyBreakdown(byMonth, bestMonth),
                      const SizedBox(height: 20),
                      _buildYearSummaryInsight(
                        totalCaffeine: totalCaffeine,
                        activeDays: activeDays,
                        avgDaily: avgDaily,
                        totalSessions: totalSessions,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.matchaDark, AppTheme.matchaPrimary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeYear(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Column(
            children: [
              const Text('Rekap Tahunan 🎉',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$_selectedYear',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 24,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          IconButton(
            onPressed: () => _changeYear(1),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required int totalSessions,
    required double totalGrams,
    required int activeDays,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.matchaLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.matchaAccent),
      ),
      child: Column(
        children: [
          const Text('🍵', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('$totalSessions sesi matcha',
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: AppTheme.matchaDark,
              )),
          const SizedBox(height: 4),
          Text(
            'selama $_selectedYear — ${totalGrams.toStringAsFixed(1)} gram total '
            'dalam $activeDays hari aktif',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13, color: AppTheme.textMedium, height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid({
    required double totalCaffeine,
    required double avgDaily,
    required String favType,
    required int? bestMonth,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _gridCard('⚡', 'Total Kafein',
            '${(totalCaffeine / 1000).toStringAsFixed(1)} g',
            AppTheme.matchaPrimary),
        _gridCard('📈', 'Rata-rata/Hari',
            '${avgDaily.toStringAsFixed(0)} mg',
            AppTheme.matchaDark),
        _gridCard('🏅', 'Favorit',
            favType, AppTheme.matchaSecondary),
        _gridCard('🌟', 'Bulan Terbaik',
            bestMonth != null ? _monthShort[bestMonth - 1] : '-',
            AppTheme.matchaSage),
      ],
    );
  }

  Widget _gridCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppTheme.textMedium)),
          Text(value,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> byMonth) {
    final maxVal = byMonth.values.isEmpty
        ? 1
        : byMonth.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.matchaAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sesi per Bulan',
              style: TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 14, color: AppTheme.textDark)),
          Text('$_selectedYear',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMedium)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: (maxVal + 2).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.matchaAccent.withOpacity(0.5),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _monthShort[v.toInt()],
                          style: const TextStyle(
                              fontSize: 9, color: AppTheme.textMedium),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textMedium),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (i) {
                  final month = i + 1;
                  final val   = (byMonth[month] ?? 0).toDouble();
                  final isBest = val == maxVal && maxVal > 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: isBest
                            ? AppTheme.matchaDark
                            : AppTheme.matchaPrimary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${_monthShort[group.x]}\n${rod.toY.toInt()} sesi',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(Map<int, int> byMonth, int? bestMonth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detail per Bulan',
            style: TextStyle(fontWeight: FontWeight.w700,
                fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 10),
        ...List.generate(12, (i) {
          final month   = i + 1;
          final count   = byMonth[month] ?? 0;
          final isBest  = month == bestMonth;
          final maxVal  = byMonth.values.isEmpty ? 1
              : byMonth.values.reduce((a, b) => a > b ? a : b);
          final ratio   = maxVal > 0 ? count / maxVal : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isBest
                  ? AppTheme.matchaPrimary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBest ? AppTheme.matchaPrimary : AppTheme.matchaAccent,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(_monthShort[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isBest
                            ? AppTheme.matchaPrimary
                            : AppTheme.textMedium,
                      )),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppTheme.matchaAccent.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBest
                            ? AppTheme.matchaDark
                            : AppTheme.matchaPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('$count sesi',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: isBest
                          ? AppTheme.matchaPrimary
                          : AppTheme.textDark,
                    )),
                if (isBest) ...[
                  const SizedBox(width: 4),
                  const Text('🏆', style: TextStyle(fontSize: 12)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildYearSummaryInsight({
    required double totalCaffeine,
    required int activeDays,
    required double avgDaily,
    required int totalSessions,
  }) {
    String title, body, emoji;
    Color color;

    if (totalSessions == 0) {
      title = 'Belum ada data';
      body  = 'Mulai catat konsumsi matcha kamu di Health Tracker!';
      emoji = '📭';
      color = AppTheme.matchaSage;
    } else if (avgDaily > HealthTrackerProvider.dailyCaffeineLimit) {
      title = 'Perlu perhatian';
      body  = 'Rata-rata kafein harian kamu di $_selectedYear melebihi batas aman. '
              'Yuk kurangi konsumsi sedikit demi sedikit di tahun berikutnya!';
      emoji = '⚠️';
      color = Colors.orange.shade500;
    } else if (activeDays >= 200) {
      title = 'Matcha enthusiast sejati!';
      body  = 'Kamu konsisten menikmati matcha selama $activeDays hari di $_selectedYear. '
              'Total $totalSessions sesi dengan pola kafein yang sehat. Luar biasa!';
      emoji = '🏆';
      color = AppTheme.matchaPrimary;
    } else {
      title = 'Tahun yang baik!';
      body  = 'Kamu menikmati $totalSessions sesi matcha di $_selectedYear dengan '
              'rata-rata kafein ${avgDaily.toStringAsFixed(0)} mg/hari — dalam batas aman.';
      emoji = '✨';
      color = AppTheme.matchaDark;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: color,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                fontSize: 13, color: AppTheme.textDark, height: 1.5,
              )),
        ],
      ),
    );
  }
}