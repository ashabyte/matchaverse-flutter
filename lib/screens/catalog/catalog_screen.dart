import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/matcha_provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchaProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Katalog Matcha'),
        actions: [
          IconButton(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<MatchaProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: provider.searchProducts,
                  decoration: InputDecoration(
                    hintText: 'Cari produk matcha...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.matchaPrimary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              provider.searchProducts('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Category filter
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MatchaProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final cat = MatchaProvider.categories[i];
                    final selected = provider.selectedCategory == cat;
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => provider.filterByCategory(cat),
                      selectedColor: AppTheme.matchaPrimary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.matchaPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Product grid
              Expanded(
                child: provider.productsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.products.isEmpty
                        ? const Center(child: Text('Tidak ada produk ditemukan'))
                        : RefreshIndicator(
                            onRefresh: provider.fetchProducts,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: provider.products.length,
                              itemBuilder: (ctx, i) {
                                final p = provider.products[i];
                                return GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.productDetail,
                                    arguments: {'id': p.id},
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 110,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppTheme.matchaLight, AppTheme.matchaAccent],
                                            ),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              p.category == 'Minuman' ? '🍵' :
                                              p.category == 'Dessert' ? '🍰' :
                                              p.category == 'Snack' ? '🍪' :
                                              p.category == 'Ceremonial' ? '🏮' : '🌿',
                                              style: const TextStyle(fontSize: 40),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                              const SizedBox(height: 4),
                                              Text('Rp ${p.price.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                      fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.matchaPrimary)),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, size: 12, color: AppTheme.matchaGold),
                                                  Text(' ${p.rating}',
                                                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCat = 'Minuman';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Produk Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga (Rp)'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: MatchaProvider.categories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => selectedCat = v!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: panggil provider.createProduct(...)
                  },
                  child: const Text('Simpan Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}