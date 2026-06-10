import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matcha_product.dart';
import '../models/matcha_recipe.dart';
import '../models/matcha_news.dart';
import '../models/intake_record.dart';
import '../models/mission.dart';
import '../models/badge_model.dart';
import '../models/leaderboard_entry.dart';
import '../models/community_post.dart';

class ApiService {
  // ⚠️ Ganti dengan IP server Node.js kamu
  static const String baseUrl = 'http://10.82.60.51:5000/api';

  static Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<T> _get<T>(String path, String? token, T Function(dynamic) fromJson) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers(token));
    if (res.statusCode == 200) {
      return fromJson(jsonDecode(res.body));
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  static Future<T> _post<T>(String path, Map<String, dynamic> body, String? token, T Function(dynamic) fromJson) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return fromJson(jsonDecode(res.body));
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  static Future<void> _put(String path, Map<String, dynamic> body, String token) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('PUT $path failed: ${res.statusCode}');
    }
  }

  static Future<void> _delete(String path, String token) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers(token));
    if (res.statusCode != 200) {
      throw Exception('DELETE $path failed: ${res.statusCode}');
    }
  }

  // ====== AUTH ======

  static Future<void> syncUserToBackend({
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
    required String token,
  }) async {
    await _post('/auth/sync', {
      'uid': uid,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
    }, token, (d) => d);
  }

  // ====== PRODUCTS ======

  static Future<List<MatchaProduct>> getProducts() async {
    return _get('/products', null, (d) =>
        (d['data'] as List).map((e) => MatchaProduct.fromJson(e)).toList());
  }

  static Future<MatchaProduct> createProduct(MatchaProduct product, String token) async {
    return _post('/products', product.toJson(), token,
        (d) => MatchaProduct.fromJson(d['data']));
  }

  static Future<void> updateProduct(MatchaProduct product, String token) async {
    await _put('/products/${product.id}', product.toJson(), token);
  }

  static Future<void> deleteProduct(String id, String token) async {
    await _delete('/products/$id', token);
  }

  // ====== RECIPES ======

  static Future<List<MatchaRecipe>> getRecipes() async {
    return _get('/recipes', null, (d) =>
        (d['data'] as List).map((e) => MatchaRecipe.fromJson(e)).toList());
  }

  static Future<MatchaRecipe> createRecipe(MatchaRecipe recipe, String token) async {
    return _post('/recipes', recipe.toJson(), token,
        (d) => MatchaRecipe.fromJson(d['data']));
  }

  static Future<void> updateRecipe(MatchaRecipe recipe, String token) async {
    await _put('/recipes/${recipe.id}', recipe.toJson(), token);
  }

  static Future<void> deleteRecipe(String id, String token) async {
    await _delete('/recipes/$id', token);
  }

  // ====== NEWS & FUN FACTS ======

  static Future<List<MatchaNews>> getNews() async {
    return _get('/news', null, (d) =>
        (d['data'] as List).map((e) => MatchaNews.fromJson(e)).toList());
  }

  static Future<List<String>> getFunFacts() async {
    return _get('/funfacts', null, (d) =>
        (d['data'] as List).map((e) => e['fact'].toString()).toList());
  }

  // ====== HEALTH TRACKER ======

  static Future<List<IntakeRecord>> getIntakeRecords(
    String userId, String token, {
    String? date, int? year, int? month,
  }) async {
    String query = '?userId=$userId';
    if (date != null) query += '&date=$date';
    if (year != null) query += '&year=$year';
    if (month != null) query += '&month=$month';
    return _get('/intake$query', token, (d) =>
        (d['data'] as List).map((e) => IntakeRecord.fromJson(e)).toList());
  }

  static Future<IntakeRecord> createIntakeRecord(IntakeRecord record, String token) async {
    return _post('/intake', record.toJson(), token,
        (d) => IntakeRecord.fromJson(d['data']));
  }

  static Future<void> updateIntakeRecord(IntakeRecord record, String token) async {
    await _put('/intake/${record.id}', record.toJson(), token);
  }

  static Future<void> deleteIntakeRecord(String id, String token) async {
    await _delete('/intake/$id', token);
  }

  static Future<Map<String, dynamic>> getYearlyStats(
      String userId, String token, int year) async {
    return _get('/intake/yearly?userId=$userId&year=$year', token,
        (d) => d['data'] as Map<String, dynamic>);
  }

  // ====== GAMIFICATION ======

  static Future<List<Mission>> getMissions(String userId, String token, {String type = 'daily'}) async {
    return _get('/missions?userId=$userId&type=$type', token, (d) =>
        (d['data'] as List).map((e) => Mission.fromJson(e)).toList());
  }

  static Future<List<BadgeModel>> getBadges(String userId, String token) async {
    return _get('/badges?userId=$userId', token, (d) =>
        (d['data'] as List).map((e) => BadgeModel.fromJson(e)).toList());
  }

  static Future<List<LeaderboardEntry>> getLeaderboard(String token) async {
    return _get('/leaderboard', token, (d) =>
        (d['data'] as List).map((e) => LeaderboardEntry.fromJson(e)).toList());
  }

  static Future<Map<String, dynamic>> getUserGameStats(String userId, String token) async {
    return _get('/gamification/stats/$userId', token,
        (d) => d['data'] as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> completeMission(
      String missionId, String userId, String token) async {
    return _post('/missions/complete', {'missionId': missionId, 'userId': userId},
        token, (d) => d['data'] as Map<String, dynamic>);
  }

  // ====== COMMUNITY ======

  static Future<List<CommunityPost>> getCommunityPosts({int page = 1}) async {
    return _get('/posts?page=$page&limit=10', null, (d) =>
        (d['data'] as List).map((e) => CommunityPost.fromJson(e)).toList());
  }

  static Future<CommunityPost> createPost(CommunityPost post, String token) async {
    return _post('/posts', post.toJson(), token,
        (d) => CommunityPost.fromJson(d['data']));
  }

  static Future<void> deletePost(String id, String token) async {
    await _delete('/posts/$id', token);
  }

  static Future<void> likePost(String postId, String userId, String token) async {
    await _post('/posts/$postId/like', {'userId': userId}, token, (d) => d);
  }
}