import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'add_edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  final Category category;
  const ManageProductsScreen({super.key, required this.category});
  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<Product> _products = [];
  Product? _pendingDelete;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = context.read<SalesProvider>();
    final prods = await provider.getAllProductsForCategory(widget.category.id!);
    setState(() => _products = prods.where((p) => !p.isDeleted).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة منتجات — ${widget.category.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addProduct,
            tooltip: 'إضافة نوع',
          ),
        ],
      ),
      body: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  const Text('لا توجد منتجات', style: TextStyle(fontSize: 17, color: AppTheme.textMuted)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة نوع جديد'),
                    onPressed: _addProduct,
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              onReorder: _onReorder,
              itemBuilder: (ctx, i) => _ProductTile(
                key: ValueKey(_products[i].id),
                product: _products[i],
                onEdit: () => _editProduct(_products[i]),
                onToggle: () => _toggleProduct(_products[i]),
                onDelete: () => _confirmDelete(_products[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('إضافة نوع'),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _products.removeAt(oldIndex);
      _products.insert(newIndex, item);
    });
    context.read<SalesProvider>().reorderProducts(_products);
  }

  void _addProduct() async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddEditProductScreen(categoryId: widget.category.id!, isDynamic: widget.category.isDynamic),
    ));
    if (result == true) await _loadProducts();
  }

  void _editProduct(Product product) async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddEditProductScreen(product: product, categoryId: widget.category.id!, isDynamic: widget.category.isDynamic),
    ));
    if (result == true) await _loadProducts();
  }

  void _toggleProduct(Product product) async {
    final updated = product.copyWith(isActive: !product.isActive);
    await context.read<SalesProvider>().updateProduct(updated);
    await _loadProducts();
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${product.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SalesProvider>().softDeleteProduct(product.id!);
              await _loadProducts();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف "${product.name}"'),
                    action: SnackBarAction(
                      label: 'تراجع',
                      textColor: Colors.white,
                      onPressed: () async {
                        await context.read<SalesProvider>().restoreProduct(product.id!);
                        await _loadProducts();
                      },
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: product.isActive ? Colors.white : AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: ReorderableDragStartListener(
          index: 0,
          child: const Icon(Icons.drag_handle, color: AppTheme.textMuted),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: product.isActive ? AppTheme.textPrimary : AppTheme.textMuted,
            decoration: product.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '${formatPrice(product.price)} / ${product.unit}',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.isActive,
              onChanged: (_) => onToggle(),
              activeColor: AppTheme.primary,
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
