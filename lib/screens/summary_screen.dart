import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../models/category.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../services/pdf_service.dart';

class SummaryScreen extends StatefulWidget {
  final String? date;
  const SummaryScreen({super.key, this.date});
  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SaleSession? _session;
  List<SaleItem> _items = [];
  bool _loading = true;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? todayDateString();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final provider = context.read<SalesProvider>();
    final session = await provider.getSessionByDate(_selectedDate!);
    if (session != null) {
      final items = await provider.getItemsForSession(session.id!);
      setState(() {
        _session = session;
        _items = items;
        _loading = false;
      });
    } else {
      setState(() {
        _session = null;
        _items = [];
        _loading = false;
      });
    }
  }

  Map<String, List<SaleItem>> _groupByCategory() {
    final provider = context.read<SalesProvider>();
    final Map<String, List<SaleItem>> grouped = {};
    for (final item in _items) {
      // Find category name
      String catName = 'أخرى';
      for (final cat in provider.categories) {
        final products = provider.productsByCategory[cat.id] ?? [];
        if (products.any((p) => p.id == item.productId)) {
          catName = cat.name;
          break;
        }
      }
      grouped.putIfAbsent(catName, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملخص اليوم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickDate,
            tooltip: 'اختر تاريخاً',
          ),
          if (_session != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _exportPdf,
              tooltip: 'تصدير PDF',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _session == null
              ? _buildEmpty()
              : _buildSummary(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 72, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'لا توجد مبيعات في ${formatDateArabic(_selectedDate!)}',
            style: const TextStyle(fontSize: 17, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة للبيع'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final grouped = _groupByCategory();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date header
          _SummaryHeader(session: _session!, date: _selectedDate!),
          const SizedBox(height: 16),
          // Categories
          ...grouped.entries.map((entry) => _CategorySummaryCard(
            categoryName: entry.key,
            items: entry.value,
          )),
          const SizedBox(height: 16),
          // Grand total
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المجموع العام',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                Text(
                  formatPrice(_session!.grandTotal),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('تصدير PDF'),
                  onPressed: _exportPdf,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_selectedDate!) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      _selectedDate = '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
      await _loadData();
    }
  }

  Future<void> _exportPdf() async {
    if (_session == null) return;
    final provider = context.read<SalesProvider>();
    try {
      await PdfService.generateAndShareDailySummary(
        session: _session!,
        items: _items,
        categories: provider.categories,
        productsByCategory: provider.productsByCategory,
        shopName: provider.settings.shopName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء PDF: $e')),
        );
      }
    }
  }
}

class _SummaryHeader extends StatelessWidget {
  final SaleSession session;
  final String date;
  const _SummaryHeader({required this.session, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('التاريخ', style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
              Text(formatDateArabic(date),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عدد المعاملات', style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
              Text('${session.transactionCount}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySummaryCard extends StatelessWidget {
  final String categoryName;
  final List<SaleItem> items;
  const _CategorySummaryCard({required this.categoryName, required this.items});

  @override
  Widget build(BuildContext context) {
    final categoryTotal = items.fold(0.0, (sum, i) => sum + i.total);
    // Group by product name and sum quantities
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final item in items) {
      if (grouped.containsKey(item.productName)) {
        grouped[item.productName]!['qty'] = (grouped[item.productName]!['qty'] as double) + item.quantity;
        grouped[item.productName]!['total'] = (grouped[item.productName]!['total'] as double) + item.total;
      } else {
        grouped[item.productName] = {
          'qty': item.quantity,
          'price': item.productPrice,
          'unit': item.productUnit,
          'total': item.total,
        };
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(categoryName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                Text(formatPrice(categoryTotal),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryDark)),
              ],
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Expanded(child: Text('المنتج', style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                SizedBox(width: 60, child: Text('الكمية', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                SizedBox(width: 70, child: Text('الثمن', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
                SizedBox(width: 80, child: Text('المجموع', textAlign: TextAlign.end, style: TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...grouped.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                SizedBox(width: 60, child: Text(formatQuantity(e.value['qty']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15))),
                SizedBox(width: 70, child: Text(formatPriceShort(e.value['price']), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary))),
                SizedBox(width: 80, child: Text(formatPrice(e.value['total']), textAlign: TextAlign.end, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مجموع الفئة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                Text(formatPrice(categoryTotal),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
