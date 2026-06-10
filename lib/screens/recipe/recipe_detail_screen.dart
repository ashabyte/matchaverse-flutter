import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/matcha_recipe.dart';
import '../../providers/matcha_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MatchaProvider>();
    final recipe = provider.recipes.firstWhere(
      (r) => r.id == recipeId,
      orElse: () => MatchaRecipe(id: '', title: 'Resep tidak ditemukan', description: '',
          ingredients: [], steps: [], imageUrl: '', servings: 1, prepTime: 0,
          difficulty: 'Mudah', authorId: '', authorName: '', createdAt: DateTime.now()),
    );
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 160, decoration: BoxDecoration(
              color: AppTheme.matchaLight, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('📖', style: TextStyle(fontSize: 60)))),
          const SizedBox(height: 16),
          Row(children: [
            _chip('⏱ ${recipe.prepTime} menit'), const SizedBox(width: 8),
            _chip('👥 ${recipe.servings} porsi'), const SizedBox(width: 8),
            _chip('📊 ${recipe.difficulty}'),
          ]),
          const SizedBox(height: 16),
          Text(recipe.description, style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, height: 1.6)),
          const SizedBox(height: 20),
          const Text('Bahan-bahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          ...recipe.ingredients.map((ing) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Text('• ', style: TextStyle(color: AppTheme.matchaPrimary, fontSize: 16)),
              Expanded(child: Text(ing, style: const TextStyle(fontSize: 14, color: AppTheme.textDark))),
            ]),
          )),
          const SizedBox(height: 20),
          const Text('Langkah-langkah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.matchaAccent.withOpacity(0.4))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppTheme.matchaPrimary, shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 10),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.5))),
            ]),
          )),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _chip(String label) => Chip(
    label: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.matchaPrimary)),
    backgroundColor: AppTheme.matchaLight, padding: EdgeInsets.zero,
  );
}