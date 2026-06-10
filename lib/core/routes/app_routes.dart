import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/catalog/catalog_screen.dart';
import '../../screens/catalog/product_detail_screen.dart';
import '../../screens/recipe/recipe_screen.dart';
import '../../screens/recipe/recipe_detail_screen.dart';
import '../../screens/recipe/add_recipe_screen.dart';
import '../../screens/health/health_tracker_screen.dart';
import '../../screens/health/daily_intake_screen.dart';
import '../../screens/health/monthly_recap_screen.dart';
import '../../screens/health/yearly_wrapped_screen.dart';
import '../../screens/community/community_screen.dart';
import '../../screens/community/post_detail_screen.dart';
import '../../screens/community/create_post_screen.dart';
import '../../screens/gamification/gamification_screen.dart';
import '../../screens/ai/ai_recommendation_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String catalog = '/catalog';
  static const String productDetail = '/product-detail';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipe-detail';
  static const String addRecipe = '/add-recipe';
  static const String healthTracker = '/health-tracker';
  static const String dailyIntake = '/daily-intake';
  static const String monthlyRecap = '/monthly-recap';
  static const String yearlyWrapped = '/yearly-wrapped';
  static const String community = '/community';
  static const String postDetail = '/post-detail';
  static const String createPost = '/create-post';
  static const String gamification = '/gamification';
  static const String aiRecommendation = '/ai-recommendation';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case explore:
        return _buildRoute(const ExploreScreen(), settings);
      case catalog:
        return _buildRoute(const CatalogScreen(), settings);
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(ProductDetailScreen(productId: args?['id'] ?? ''), settings);
      case recipes:
        return _buildRoute(const RecipeScreen(), settings);
      case recipeDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(RecipeDetailScreen(recipeId: args?['id'] ?? ''), settings);
      case addRecipe:
        return _buildRoute(const AddRecipeScreen(), settings);
      case healthTracker:
        return _buildRoute(const HealthTrackerScreen(), settings);
      case dailyIntake:
        return _buildRoute(const DailyIntakeScreen(), settings);
      case monthlyRecap:
        return _buildRoute(const MonthlyRecapScreen(), settings);
      case yearlyWrapped:
        return _buildRoute(const YearlyWrappedScreen(), settings);
      case community:
        return _buildRoute(const CommunityScreen(), settings);
      case postDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(PostDetailScreen(postId: args?['id'] ?? ''), settings);
      case createPost:
        return _buildRoute(const CreatePostScreen(), settings);
      case gamification:
        return _buildRoute(const GamificationScreen(), settings);
      case aiRecommendation:
        return _buildRoute(const AiRecommendationScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      default:
        return _buildRoute(const HomeScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
    );
  }
}
