import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matcha_provider.dart';
import '../../providers/health_tracker_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../services/socket_service.dart';
import '../explore/explore_screen.dart';
import '../health/health_tracker_screen.dart';
import '../community/community_screen.dart';
import '../gamification/gamification_screen.dart';
import 'home_dashboard_full.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboard(),
    ExploreScreen(),
    HealthTrackerScreen(),
    CommunityScreen(),
    GamificationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      // Connect WebSocket
      SocketService.connect(auth.user!.uid);

      // Fetch initial data
      context.read<MatchaProvider>()
        ..fetchProducts()
        ..fetchNews()
        ..fetchRecipes();

      context.read<HealthTrackerProvider>().fetchTodayRecords(
        auth.user!.uid,
        auth.authToken ?? '',
      );

      context.read<GamificationProvider>()
        ..fetchMissions(auth.user!.uid, auth.authToken ?? '')
        ..fetchBadges(auth.user!.uid, auth.authToken ?? '')
        ..fetchLeaderboard(auth.authToken ?? '')
        ..fetchUserStats(auth.user!.uid, auth.authToken ?? '');
    }
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.matchaPrimary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.matchaPrimary,
        unselectedItemColor: AppTheme.matchaSage,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Eksplorasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Kesehatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Gamifikasi',
          ),
        ],
      ),
    );
  }
}
