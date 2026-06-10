import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/matcha_recipe.dart';
import '../../providers/matcha_provider.dart';
import '../../providers/auth_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});
  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ingredientCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  String _difficulty = 'Mudah';
  int _servings = 1;
  int _prepTime = 15;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _ingredientCtrl.dispose(); _stepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Tambah Resep Baru'), actions: [
        TextButton(onPressed: _isLoading ? null : _submit,
          child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Judul Resep')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Porsi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
              Row(children: [
                IconButton(onPressed: () => setState(() => _servings = (_servings - 1).clamp(1, 20)), icon: const Icon(Icons.remove_circle_outline)),
                Text('$_servings', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => setState(() => _servings++), icon: const Icon(Icons.add_circle_outline)),
              ]),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Waktu (menit)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textDark)),
              Row(children: [
                IconButton(onPressed: () => setState(() => _prepTime = (_prepTime - 5).clamp(5, 180)), icon: const Icon(Icons.remove_circle_outline)),
                Text('$_prepTime', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => setState(() => _prepTime += 5), icon: const Icon(Icons.add_circle_outline)),
              ]),
            ])),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _difficulty,
            items: ['Mudah', 'Sedang', 'Sulit'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => _difficulty = v!),
            decoration: const InputDecoration(labelText: 'Tingkat Kesulitan'),
          ),
          const SizedBox(height: 20),
          const Text('Bahan-bahan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _ingredientCtrl, decoration: const InputDecoration(hintText: 'Contoh: 2g matcha powder'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {
              if (_ingredientCtrl.text.trim().isNotEmpty) setState(() { _ingredients.add(_ingredientCtrl.text.trim()); _ingredientCtrl.clear(); });
            }, child: const Text('+')),
          ]),
          ..._ingredients.asMap().entries.map((e) => ListTile(
            dense: true, leading: const Text('•', style: TextStyle(color: AppTheme.matchaPrimary)),
            title: Text(e.value),
            trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _ingredients.removeAt(e.key))),
          )),
          const SizedBox(height: 16),
          const Text('Langkah-langkah', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _stepCtrl, decoration: const InputDecoration(hintText: 'Tulis langkah...'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {
              if (_stepCtrl.text.trim().isNotEmpty) setState(() { _steps.add(_stepCtrl.text.trim()); _stepCtrl.clear(); });
            }, child: const Text('+')),
          ]),
          ..._steps.asMap().entries.map((e) => ListTile(
            dense: true, leading: CircleAvatar(radius: 12, backgroundColor: AppTheme.matchaPrimary,
              child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 10))),
            title: Text(e.value),
            trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _steps.removeAt(e.key))),
          )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _ingredients.isEmpty || _steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul, bahan, dan langkah wajib diisi')));
      return;
    }
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final recipe = MatchaRecipe(
      id: '', title: _titleCtrl.text, description: _descCtrl.text,
      ingredients: _ingredients, steps: _steps, imageUrl: '',
      servings: _servings, prepTime: _prepTime, difficulty: _difficulty,
      authorId: auth.user!.uid, authorName: auth.user!.displayName ?? '',
      createdAt: DateTime.now(),
    );
    final ok = await context.read<MatchaProvider>().addRecipe(recipe, auth.authToken!);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resep berhasil ditambahkan!'), backgroundColor: AppTheme.matchaPrimary)); }
  }
}