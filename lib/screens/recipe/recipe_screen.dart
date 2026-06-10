import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/matcha_provider.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});
  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MatchaProvider>().fetchRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Resep Matcha'), actions: [
        IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.addRecipe), icon: const Icon(Icons.add)),
      ]),
      body: Consumer<MatchaProvider>(
        builder: (_, provider, __) {
          if (provider.recipesLoading) return const Center(child: CircularProgressIndicator());
          if (provider.recipes.isEmpty) return const Center(child: Text('Belum ada resep. Tambahkan resep pertamamu!'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final r = provider.recipes[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(ctx, AppRoutes.recipeDetail, arguments: {'id': r.id}),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
                  child: Row(
                    children: [
                      Container(width: 64, height: 64,
                        decoration: BoxDecoration(color: AppTheme.matchaLight, borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('📖', style: TextStyle(fontSize: 28)))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          Text('${r.prepTime} menit • ${r.difficulty} • ${r.servings} porsi',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                          Text('oleh ${r.authorName}', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                        ],
                      )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}