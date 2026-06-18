import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  final int categoryId;
  final bool isDynamic;
  const AddEditProductScreen({
    super.key,
    this.product,
    required this.categoryId,
    this.isDynamic = false,
  });
  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _notesCtrl;
  String _selectedUnit = 'وحدة';
  bool _isActive = true;

  final List<String> _units = ['وحدة', 'فنجان', 'كيلوغرام', 'غرام', 'قطعة', 'علبة', 'قنينة', 'لتر', 'سنتيلتر'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.product?.notes ?? '');
    _selectedUnit = widget.product?.unit ?? (widget.isDynamic ? 'كيلوغرام' : 'فنجان');
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'تعديل المنتج' : 'إضافة نوع جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _label('الاسم'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'اسم المنتج'),
              style: const TextStyle(fontSize: 17),
              validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم' : null,
            ),
            const SizedBox(height: 20),
            _label('الثمن'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'مثال: 8.5', suffix: Text('درهم')),
              style: const TextStyle(fontSize: 17),
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء إدخال الثمن';
                if (double.tryParse(v) == null) return 'ثمن غير صحيح';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _label('الوحدة'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.divider)),
                filled: true,
                fillColor: AppTheme.surface,
              ),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 16)))).toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
            const SizedBox(height: 20),
            _label('ملاحظات اختيارية'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'ملاحظات...'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('مفعّل', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'حفظ التعديلات' : 'إضافة المنتج'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SalesProvider>();
    final product = Product(
      id: widget.product?.id,
      categoryId: widget.categoryId,
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      unit: _selectedUnit,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      isActive: _isActive,
      sortOrder: widget.product?.sortOrder ?? 0,
    );
    if (widget.product != null) {
      await provider.updateProduct(product);
    } else {
      await provider.addProduct(product);
    }
    if (mounted) Navigator.pop(context, true);
  }
}
