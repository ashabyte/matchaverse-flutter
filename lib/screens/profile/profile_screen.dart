import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_tracker_provider.dart';
import '../../providers/gamification_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.user == null) return const Center(child: Text('Belum login'));
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.matchaDark, AppTheme.matchaPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: auth.user!.photoURL != null ? NetworkImage(auth.user!.photoURL!) : null,
                        backgroundColor: AppTheme.matchaAccent,
                        child: auth.user!.photoURL == null ? const Text('🍵', style: TextStyle(fontSize: 36)) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(auth.user!.displayName ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(auth.user!.email ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _statCard(context, 'Poin', Consumer<GamificationProvider>(
                        builder: (_, g, __) => Text('${g.userPoints}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.matchaPrimary)),
                      )),
                      const SizedBox(width: 12),
                      _statCard(context, 'Ranking', Consumer<GamificationProvider>(
                        builder: (_, g, __) => Text('#${g.userRank}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.matchaGold)),
                      )),
                      const SizedBox(width: 12),
                      _statCard(context, 'Badge', Consumer<GamificationProvider>(
                        builder: (_, g, __) => Text('${g.earnedBadges.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.purple)),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu items
                _menuItem(context, '💚', 'Health Tracker', 'Pantau konsumsi matcha harian', AppRoutes.healthTracker),
                _menuItem(context, '📊', 'Rekap Bulanan', 'Lihat grafik konsumsi bulanan', AppRoutes.monthlyRecap),
                _menuItem(context, '🎁', 'Yearly Wrapped', 'Rekap perjalanan matcha tahunan', AppRoutes.yearlyWrapped),
                _menuItem(context, '🏆', 'Gamifikasi', 'Misi, badge, dan leaderboard', AppRoutes.gamification),

                const SizedBox(height: 16),

                // Logout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Keluar?'),
                            content: const Text('Kamu akan keluar dari akun MatchaVerse.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                              ElevatedButton(onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Keluar')),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await auth.signOut();
                          if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, Widget valueWidget) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          children: [
            valueWidget,
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, String emoji, String title, String subtitle, String route) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}