import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_tracker_provider.dart';

class MonthlyRecapScreen extends StatefulWidget {
  const MonthlyRecapScreen({super.key});

  @override
  State<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _fetchData();
  }

  void _fetchData() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      context.read<HealthTrackerProvider>().fetchMonthlyRecords(
        auth.user!.uid, auth.authToken ?? '',
        _selectedYear, _selectedMonth,
      );
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) { _selectedMonth = 1; _selectedYear++; }
      if (_selectedMonth < 1)  { _selectedMonth = 12; _selectedYear--; }
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Rekap Bulanan')),
      body: Consumer<HealthTrackerProvider>(
        builder: (context, provider, _) {
          final records   = provider.monthlyRecords;
          final byDay     = provider.monthlySummaryByDay;
          final daysInMonth = DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);

          // Stats
          final totalCaffeine = records.fold(0.0, (s, r) => s + r.caffeineAmount);
          final totalGrams    = records.fold(0.0, (s, r) => s + r.gramsConsumed);
          final activeDays    = byDay.keys.length;
          final avgCaffeine   = activeDays > 0 ? totalCaffeine / activeDays : 0.0;
          final maxEntry      = byDay.isEmpty ? null
              : byDay.entries.reduce((a, b) => a.value > b.value ? a : b);

          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthSelector(),
                      const SizedBox(height: 16),
                      _buildStatCards(
                        totalCaffeine: totalCaffeine,
                        totalGrams: totalGrams,
                        activeDays: activeDays,
                        avgCaffeine: avgCaffeine,
                        maxEntry: maxEntry,
                        daysInMonth: daysInMonth,
                      ),
                      const SizedBox(height: 20),
                      _buildChartSection(byDay, daysInMonth),
                      const SizedBox(height: 20),
                      _buildInsightSection(
                        totalCaffeine: totalCaffeine,
                        activeDays: activeDays,
                        avgCaffeine: avgCaffeine,
                        daysInMonth: daysInMonth,
                      ),
                      const SizedBox(height: 20),
                      _buildRecentList(records),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.matchaPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Column(
            children: [
              Text(
                _monthNames[_selectedMonth - 1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$_selectedYear',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards({
    required double totalCaffeine,
    required double totalGrams,
    required int activeDays,
    required double avgCaffeine,
    required MapEntry<int, double>? maxEntry,
    required int daysInMonth,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('☕', 'Total Kafein',
                '${totalCaffeine.toStringAsFixed(0)} mg', AppTheme.matchaPrimary)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('🍵', 'Total Matcha',
                '${totalGrams.toStringAsFixed(1)} g', AppTheme.matchaDark)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statCard('📅', 'Hari Aktif',
                '$activeDays / $daysInMonth hari', AppTheme.matchaSecondary)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('📊', 'Rata-rata/Hari',
                '${avgCaffeine.toStringAsFixed(0)} mg', AppTheme.matchaSage)),
          ],
        ),
        if (maxEntry != null) ...[
          const SizedBox(height: 10),
          _statCardWide('🏆', 'Hari Tertinggi',
              'Tanggal ${maxEntry.key} — ${maxEntry.value.toStringAsFixed(0)} mg kafein'),
        ],
      ],
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textMedium)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: color,
          )),
        ],
      ),
    );
  }

  Widget _statCardWide(String emoji, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.matchaLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.matchaAccent),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                fontSize: 11, color: AppTheme.textMedium,
              )),
              Text(value, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppTheme.matchaDark,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<int, double> byDay, int daysInMonth) {
    final spots = List.generate(daysInMonth, (i) {
      final day = i + 1;
      return FlSpot(day.toDouble(), (byDay[day] ?? 0.0));
    });

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
          const Text('Kafein Harian (mg)',
              style: TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text('${_monthNames[_selectedMonth - 1]} $_selectedYear',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.matchaAccent.withOpacity(0.5),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10,
                            color: AppTheme.textMedium),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 10,
                            color: AppTheme.textMedium),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.matchaPrimary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: spot.y > 0 ? 3 : 0,
                        color: AppTheme.matchaPrimary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.matchaPrimary.withOpacity(0.08),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) =>
                      LineTooltipItem(
                        'Tgl ${s.x.toInt()}\n${s.y.toStringAsFixed(0)} mg',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection({
    required double totalCaffeine,
    required int activeDays,
    required double avgCaffeine,
    required int daysInMonth,
  }) {
    final consistency = (activeDays / daysInMonth * 100).toStringAsFixed(0);
    final isHealthy   = avgCaffeine <= HealthTrackerProvider.dailyCaffeineLimit;

    String insightText;
    Color insightColor;
    String insightEmoji;

    if (activeDays == 0) {
      insightText  = 'Belum ada data untuk bulan ini.';
      insightColor = AppTheme.matchaSage;
      insightEmoji = '📭';
    } else if (avgCaffeine > HealthTrackerProvider.dailyCaffeineLimit) {
      insightText  = 'Rata-rata kafein kamu melebihi batas aman (${HealthTrackerProvider.dailyCaffeineLimit.toStringAsFixed(0)} mg). Pertimbangkan untuk mengurangi konsumsi matcha.';
      insightColor = Colors.red.shade400;
      insightEmoji = '⚠️';
    } else if (avgCaffeine > HealthTrackerProvider.dailyCaffeineLimit * 0.8) {
      insightText  = 'Konsumsi kafein kamu mendekati batas aman. Tetap jaga pola konsumsi yang sehat!';
      insightColor = Colors.orange.shade400;
      insightEmoji = '🔶';
    } else {
      insightText  = 'Konsumsi kafein kamu dalam batas aman. Pertahankan pola sehat ini!';
      insightColor = AppTheme.matchaPrimary;
      insightEmoji = '✅';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: insightColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(insightEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Insight Bulan Ini',
                  style: TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 14, color: insightColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(insightText,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              _insightChip('Konsistensi', '$consistency%'),
              const SizedBox(width: 8),
              _insightChip('Status',
                  isHealthy ? 'Sehat ✓' : 'Perlu Perhatian'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _insightChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.matchaAccent),
      ),
      child: Text('$label: $value',
          style: const TextStyle(fontSize: 11, color: AppTheme.textDark)),
    );
  }

  Widget _buildRecentList(List records) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.matchaLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Tidak ada data untuk bulan ini',
              style: TextStyle(color: AppTheme.textMedium, fontSize: 13)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Riwayat Konsumsi',
            style: TextStyle(fontWeight: FontWeight.w700,
                fontSize: 14, color: AppTheme.textDark)),
        const SizedBox(height: 10),
        ...records.take(10).map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.matchaAccent),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.matchaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('🍵', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.matchaType,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13, color: AppTheme.textDark,
                        )),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(r.consumedAt),
                      style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${r.gramsConsumed.toStringAsFixed(1)} g',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13, color: AppTheme.matchaDark,
                      )),
                  Text('${r.caffeineAmount.toStringAsFixed(0)} mg',
                      style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMedium,
                      )),
                ],
              ),
            ],
          ),
        )),
        if (records.length > 10)
          Center(
            child: Text('+${records.length - 10} data lainnya',
                style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMedium,
                )),
          ),
      ],
    );
  }
}