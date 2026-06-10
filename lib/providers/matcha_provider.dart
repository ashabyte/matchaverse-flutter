import 'package:flutter/foundation.dart';
import '../models/matcha_product.dart';
import '../models/matcha_recipe.dart';
import '../models/matcha_news.dart';
import '../services/api_service.dart';

class MatchaProvider extends ChangeNotifier {
  // Products / Catalog
  List<MatchaProduct> _products = [];
  List<MatchaProduct> _filteredProducts = [];
  bool _productsLoading = false;

  // Recipes
  List<MatchaRecipe> _recipes = [];
  bool _recipesLoading = false;

  // News & Fun Facts
  List<MatchaNews> _news = [];
  List<String> _funFacts = [];
  bool _newsLoading = false;

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  // Getters
  List<MatchaProduct> get products => _filteredProducts;
  List<MatchaProduct> get allProducts => _products;
  List<MatchaRecipe> get recipes => _recipes;
  List<MatchaNews> get news => _news;
  List<String> get funFacts => _funFacts;
  bool get productsLoading => _productsLoading;
  bool get recipesLoading => _recipesLoading;
  bool get newsLoading => _newsLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  static const List<String> categories = [
    'Semua', 'Minuman', 'Dessert', 'Makanan', 'Snack', 'Ceremonial', 'Culinary Grade'
  ];

  // ===== PRODUCTS CRUD =====

  Future<void> fetchProducts() async {
    _productsLoading = true;
    notifyListeners();
    try {
      _products = await ApiService.getProducts();
      _applyFilter();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
    _productsLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct(MatchaProduct product, String token) async {
    try {
      final created = await ApiService.createProduct(product, token);
      _products.insert(0, created);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(MatchaProduct product, String token) async {
    try {
      await ApiService.updateProduct(product, token);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId, String token) async {
    try {
      await ApiService.deleteProduct(productId, token);
      _products.removeWhere((p) => p.id == productId);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  void _applyFilter() {
    _filteredProducts = _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // ===== RECIPES =====

  Future<void> fetchRecipes() async {
    _recipesLoading = true;
    notifyListeners();
    try {
      _recipes = await ApiService.getRecipes();
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
    }
    _recipesLoading = false;
    notifyListeners();
  }

  Future<bool> addRecipe(MatchaRecipe recipe, String token) async {
    try {
      final created = await ApiService.createRecipe(recipe, token);
      _recipes.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding recipe: $e');
      return false;
    }
  }

  Future<bool> updateRecipe(MatchaRecipe recipe, String token) async {
    try {
      await ApiService.updateRecipe(recipe, token);
      final idx = _recipes.indexWhere((r) => r.id == recipe.id);
      if (idx != -1) _recipes[idx] = recipe;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId, String token) async {
    try {
      await ApiService.deleteRecipe(recipeId, token);
      _recipes.removeWhere((r) => r.id == recipeId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== NEWS & FUN FACTS =====

  Future<void> fetchNews() async {
    _newsLoading = true;
    notifyListeners();
    try {
      _news = await ApiService.getNews();
      _funFacts = await ApiService.getFunFacts();
    } catch (e) {
      debugPrint('Error fetching news: $e');
    }
    _newsLoading = false;
    notifyListeners();
  }
}
