import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matcha_provider.dart';
import '../../providers/health_tracker_provider.dart';
import '../../providers/gamification_provider.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _CaffeineWidget(),
                _FunFactCard(),
                _NewsSection(),
                _QuickActionsGrid(),
                _DailyMissionsPreview(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.matchaPrimary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.matchaDark, AppTheme.matchaPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: auth.user?.photoURL != null
                            ? NetworkImage(auth.user!.photoURL!)
                            : null,
                        backgroundColor: AppTheme.matchaAccent,
                        child: auth.user?.photoURL == null
                            ? const Text('🍵', style: TextStyle(fontSize: 18))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Halo, ${auth.user?.displayName?.split(' ').first ?? 'Matcha Lover'}! 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Selamat datang di MatchaVerse',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.aiRecommendation),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('🤖', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                        icon: const Icon(Icons.person_outline, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===================== CAFFEINE WIDGET =====================
class _CaffeineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HealthTrackerProvider>(
      builder: (context, tracker, _) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.healthTracker),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
              boxShadow: [
                BoxShadow(
                  color: AppTheme.matchaPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '☕ Kafein Hari Ini',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tracker.isOverLimit ? '⚠️ Melebihi batas' : '✅ Aman',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${tracker.todayTotalCaffeine.toStringAsFixed(0)} mg',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                ),
                Text(
                  'dari ${HealthTrackerProvider.dailyCaffeineLimit.toStringAsFixed(0)} mg batas aman',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: tracker.caffeinePercent,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tracker.todayRecords.length} sesi konsumsi hari ini • ${tracker.todayTotalGrams.toStringAsFixed(1)}g matcha',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===================== FUN FACT =====================
class _FunFactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchaProvider>(
      builder: (context, provider, _) {
        if (provider.funFacts.isEmpty) return const SizedBox(height: 16);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.matchaCream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.matchaAccent.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.matchaLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('💡', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fun Fact Matcha',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.matchaPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.funFacts.first,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===================== NEWS SECTION =====================
class _NewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchaProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('📰 Berita Matcha Terbaru',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.explore),
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            if (provider.newsLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.news.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada berita', style: TextStyle(color: AppTheme.textLight)),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.news.length.clamp(0, 5),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final news = provider.news[i];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.matchaPrimary.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 80,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                gradient: LinearGradient(
                                  colors: [AppTheme.matchaAccent, AppTheme.matchaSecondary],
                                ),
                              ),
                              child: const Center(child: Text('🍵', style: TextStyle(fontSize: 36))),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    news.source,
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// ===================== QUICK ACTIONS =====================
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA('🤖', 'AI Rekomendasi', AppRoutes.aiRecommendation, AppTheme.matchaPrimary),
      _QA('📖', 'Resep', AppRoutes.recipes, AppTheme.matchaBrown),
      _QA('🛍️', 'Katalog', AppRoutes.catalog, AppTheme.matchaGold),
      _QA('📊', 'Rekap Bulanan', AppRoutes.monthlyRecap, AppTheme.matchaMint),
      _QA('🎁', 'Yearly Wrapped', AppRoutes.yearlyWrapped, Colors.purple),
      _QA('👥', 'Komunitas', AppRoutes.community, Colors.blue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text('⚡ Akses Cepat',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: actions.map((a) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, a.route),
              child: Container(
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a.color.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(a.label, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: a.color)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _QA {
  final String emoji, label, route;
  final Color color;
  const _QA(this.emoji, this.label, this.route, this.color);
}

// ===================== DAILY MISSIONS PREVIEW =====================
class _DailyMissionsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, provider, _) {
        if (provider.dailyMissions.isEmpty) return const SizedBox();
        final missions = provider.dailyMissions.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🎯 Misi Harian',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.gamification),
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            ...missions.map((m) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: m.isCompleted ? AppTheme.matchaLight : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: m.isCompleted ? AppTheme.matchaSecondary : AppTheme.matchaAccent.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: m.isCompleted ? AppTheme.matchaPrimary : AppTheme.textDark,
                              decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                            )),
                        Text(m.description,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.matchaGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('+${m.pointsReward}pt',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.matchaGold)),
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}