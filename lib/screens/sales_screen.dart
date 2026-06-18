import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/sales_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_tab.dart';
import '../widgets/confirm_bottom_bar.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'summary_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();
    final categories = provider.categories;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (categories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.category_outlined, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              const Text('لا توجد فئات بعد', style: TextStyle(fontSize: 18, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('إضافة فئة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedCategoryIndex >= categories.length) {
      _selectedCategoryIndex = 0;
    }

    final selectedCategory = categories[_selectedCategoryIndex];
    final products = provider.productsByCategory[selectedCategory.id] ?? [];

    return Scaffold(
      body: Column(
        children: [
          // Category tabs
          CategoryTabBar(
            categories: categories,
            selectedIndex: _selectedCategoryIndex,
            onTabSelected: (i) => setState(() => _selectedCategoryIndex = i),
          ),
          const Divider(height: 1),
          // Products list
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.textMuted),
                        SizedBox(height: 12),
                        Text('لا توجد منتجات في هذه الفئة', style: TextStyle(fontSize: 17, color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) {
                      final product = products[i];
                      final qty = provider.getCartQuantity(product.id!);
                      return ProductCard(
                        product: product,
                        quantity: qty,
                        isDynamic: selectedCategory.isDynamic,
                        onAdd: () => provider.addToCart(product),
                        onRemove: () => provider.removeFromCart(product),
                        onQuantityEdit: selectedCategory.isDynamic
                            ? (newQty) {
                                // Remove old and set new quantity
                                final cart = provider.cart;
                                final existing = cart.where((c) => c.productId == product.id).firstOrNull;
                                if (existing != null) {
                                  existing.quantity = newQty;
                                  provider.notifyListeners();
                                }
                              }
                            : null,
                      );
                    },
                  ),
          ),
          // Bottom bar
          Consumer<SalesProvider>(
            builder: (ctx, prov, _) => ConfirmBottomBar(
              itemCount: prov.cartItemCount,
              total: prov.cartTotal,
              onConfirm: () => _confirmSale(context, prov),
              onClear: () => prov.clearCart(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSale(BuildContext context, SalesProvider provider) async {
    final success = await provider.confirmSale();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('✅ تم تسجيل البيع بنجاح', style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'عرض الملخص',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen()));
            },
          ),
        ),
      );
    }
  }
}
