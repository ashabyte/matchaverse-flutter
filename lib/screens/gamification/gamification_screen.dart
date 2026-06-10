import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/auth_provider.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Gamifikasi'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '🎯 Misi'),
            Tab(text: '🏅 Badge'),
            Tab(text: '🏆 Leaderboard'),
          ],
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _MissionsTab(provider: provider),
              _BadgesTab(provider: provider),
              _LeaderboardTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  final GamificationProvider provider;
  const _MissionsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.matchaDark, AppTheme.matchaPrimary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('${provider.userPoints}', 'Total Poin', '⭐'),
                _statItem('#${provider.userRank}', 'Ranking', '🏆'),
                _statItem('${provider.completedDailyCount}/${provider.dailyMissions.length}', 'Harian', '🎯'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Misi Harian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          ...provider.dailyMissions.map((m) => _MissionTile(mission: m)),
          const SizedBox(height: 20),
          const Text('Misi Mingguan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          ...provider.weeklyMissions.map((m) => _MissionTile(mission: m)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _MissionTile extends StatelessWidget {
  final dynamic mission;
  const _MissionTile({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: mission.isCompleted ? AppTheme.matchaLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: mission.isCompleted ? AppTheme.matchaSecondary : AppTheme.matchaAccent.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Text(mission.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title,
                        style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: mission.isCompleted ? AppTheme.matchaPrimary : AppTheme.textDark,
                          decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
                        )),
                    Text(mission.description, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ],
                ),
              ),
              if (mission.isCompleted)
                const Icon(Icons.check_circle, color: AppTheme.matchaPrimary, size: 24)
              else
                ElevatedButton(
                  onPressed: () => ctx.read<GamificationProvider>().completeMission(mission.id, auth.user!.uid, auth.authToken!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text('+${mission.pointsReward}pt', style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgesTab extends StatelessWidget {
  final GamificationProvider provider;
  const _BadgesTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: provider.badges.length,
      itemBuilder: (ctx, i) {
        final badge = provider.badges[i];
        return Container(
          decoration: BoxDecoration(
            color: badge.isEarned ? AppTheme.matchaLight : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badge.isEarned ? AppTheme.matchaSecondary : Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.emoji,
                  style: TextStyle(fontSize: 36, color: badge.isEarned ? null : Colors.grey)),
              const SizedBox(height: 6),
              Text(badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: badge.isEarned ? AppTheme.matchaDark : Colors.grey,
                  )),
              if (!badge.isEarned)
                const Text('Terkunci', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final GamificationProvider provider;
  const _LeaderboardTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.leaderboard.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final entry = provider.leaderboard[i];
        final isTop3 = i < 3;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isTop3 ? AppTheme.matchaLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isTop3 ? AppTheme.matchaSecondary : AppTheme.matchaAccent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isTop3 ? 22 : 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                backgroundImage: entry.photoUrl.isNotEmpty ? NetworkImage(entry.photoUrl) : null,
                backgroundColor: AppTheme.matchaAccent,
                child: entry.photoUrl.isEmpty ? const Text('🍵') : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(entry.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.matchaGold.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('${entry.points} pt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.matchaGold)),
              ),
            ],
          ),
        );
      },
    );
  }
}