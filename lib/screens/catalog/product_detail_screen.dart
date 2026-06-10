import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/matcha_product.dart';
import '../../providers/matcha_provider.dart';
import '../../providers/auth_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MatchaProvider>();
    final product = provider.allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => const MatchaProduct(
        id: '', name: 'Produk tidak ditemukan', description: '',
        category: '', price: 0, imageUrl: '', rating: 0, origin: '', grade: '',
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.matchaLight, AppTheme.matchaAccent],
                  ),
                ),
                child: Center(
                  child: Text(
                    product.category == 'Minuman' ? '🍵' :
                    product.category == 'Dessert' ? '🍰' :
                    product.category == 'Snack' ? '🍪' :
                    product.category == 'Ceremonial' ? '🏮' : '🌿',
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                      ),
                      _buildDeleteButton(context, product),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Rp ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.matchaPrimary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(product.category, AppTheme.matchaPrimary),
                      _chip(product.grade, AppTheme.matchaGold),
                      _chip('⭐ ${product.rating}', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, height: 1.6)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.matchaLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('📍 Asal: ', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                        Text(product.origin.isEmpty ? '-' : product.origin,
                            style: const TextStyle(color: AppTheme.textMedium)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildDeleteButton(BuildContext context, MatchaProduct product) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.user == null) return const SizedBox();
        return IconButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Hapus Produk?'),
                content: const Text('Produk ini akan dihapus permanen.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await context.read<MatchaProvider>().deleteProduct(product.id, auth.authToken!);
              if (context.mounted) Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        );
      },
    );
  }
}