import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isDynamic;
  final Function(double)? onQuantityEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.isDynamic = false,
    this.onQuantityEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasQty = quantity > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hasQty ? AppTheme.primary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasQty ? AppTheme.primary.withOpacity(0.35) : AppTheme.divider,
          width: hasQty ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatPrice(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      if (isDynamic) ...[
                        const SizedBox(width: 6),
                        Text(
                          '/ ${product.unit}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasQty) ...[
                  _CircleButton(
                    icon: Icons.remove,
                    onTap: onRemove,
                    color: AppTheme.textSecondary,
                    bgColor: AppTheme.divider,
                    size: 44,
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: isDynamic && onQuantityEdit != null
                        ? () => _showQuantityDialog(context)
                        : null,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 42),
                      alignment: Alignment.center,
                      child: Text(
                        formatQuantity(quantity),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _CircleButton(
                  icon: Icons.add,
                  onTap: onAdd,
                  color: Colors.white,
                  bgColor: AppTheme.primary,
                  size: 52,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    final ctrl = TextEditingController(text: formatQuantity(quantity));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل الكمية - ${product.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffix: Text(product.unit),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                onQuantityEdit!(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bgColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: size * 0.50),
        ),
      ),
    );
  }
}
