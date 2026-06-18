import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import 'manage_products_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});
  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = context.watch<SalesProvider>().categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفئات'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addCategory, tooltip: 'إضافة فئة'),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: Text('لا توجد فئات'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final updated = List<Category>.from(categories);
                final item = updated.removeAt(oldIndex);
                updated.insert(newIndex, item);
                context.read<SalesProvider>().updateCategory(
                  item.copyWith(sortOrder: newIndex),
                );
              },
              itemBuilder: (ctx, i) => _CategoryTile(
                key: ValueKey(categories[i].id),
                category: categories[i],
                onManageProducts: () => Navigator.push(ctx, MaterialPageRoute(
                  builder: (_) => ManageProductsScreen(category: categories[i]),
                )),
                onEdit: () => _editCategory(categories[i]),
                onToggle: () => _toggleCategory(categories[i]),
                onDelete: () => _confirmDelete(categories[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: const Text('إضافة فئة'),
      ),
    );
  }

  void _addCategory() => _showCategoryDialog(null);
  void _editCategory(Category cat) => _showCategoryDialog(cat);

  void _showCategoryDialog(Category? cat) {
    final ctrl = TextEditingController(text: cat?.name ?? '');
    bool isDynamic = cat?.isDynamic ?? false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(cat == null ? 'إضافة فئة جديدة' : 'تعديل الفئة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'اسم الفئة'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('فئة ديناميكية (وزن/كمية)', style: TextStyle(fontSize: 14)),
                  Switch(value: isDynamic, onChanged: (v) => setS(() => isDynamic = v), activeColor: AppTheme.primary),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                final provider = context.read<SalesProvider>();
                if (cat == null) {
                  await provider.addCategory(Category(
                    name: ctrl.text.trim(),
                    isDynamic: isDynamic,
                    sortOrder: provider.categories.length,
                  ));
                } else {
                  await provider.updateCategory(cat.copyWith(name: ctrl.text.trim(), isDynamic: isDynamic));
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCategory(Category cat) {
    context.read<SalesProvider>().updateCategory(cat.copyWith(isActive: !cat.isActive));
  }

  void _confirmDelete(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف فئة "${cat.name}"؟\nسيتم حذف جميع منتجاتها.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SalesProvider>().deleteCategory(cat.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الفئة'), backgroundColor: AppTheme.error),
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

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onManageProducts;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CategoryTile({
    super.key,
    required this.category,
    required this.onManageProducts,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: category.isActive ? Colors.white : AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ReorderableDragStartListener(
          index: 0,
          child: const Icon(Icons.drag_handle, color: AppTheme.textMuted),
        ),
        title: Text(category.name,
          style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: category.isActive ? AppTheme.textPrimary : AppTheme.textMuted,
          )),
        subtitle: Row(
          children: [
            if (category.isDynamic)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ديناميكية', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.list_alt_outlined, color: AppTheme.primary),
              onPressed: onManageProducts,
              tooltip: 'إدارة الأنواع',
            ),
            IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary), onPressed: onEdit),
            Switch(value: category.isActive, onChanged: (_) => onToggle(), activeColor: AppTheme.primary),
            IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
