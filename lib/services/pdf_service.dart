import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sale.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../utils/helpers.dart';

class PdfService {
  static Future<void> generateAndShareDailySummary({
    required SaleSession session,
    required List<SaleItem> items,
    required List<Category> categories,
    required Map<int, List<Product>> productsByCategory,
    required String shopName,
  }) async {
    final pdf = pw.Document();

    // Load Arabic font
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBold = await PdfGoogleFonts.cairoBold();

    // Group items by category
    final Map<String, List<SaleItem>> grouped = {};
    for (final item in items) {
      String catName = 'أخرى';
      for (final cat in categories) {
        final prods = productsByCategory[cat.id] ?? [];
        if (prods.any((p) => p.id == item.productId)) {
          catName = cat.name;
          break;
        }
      }
      grouped.putIfAbsent(catName, () => []).add(item);
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBold),
      build: (context) {
        final widgets = <pw.Widget>[];

        // Header
        widgets.add(pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('5C3317'),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shopName,
                style: pw.TextStyle(font: arabicBold, fontSize: 28, color: PdfColors.white),
                textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 6),
              pw.Text('ملخص المبيعات اليومية',
                style: pw.TextStyle(font: arabicFont, fontSize: 16, color: PdfColor.fromHex('F5D3B0')),
                textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 6),
              pw.Text(formatDateArabic(session.date),
                style: pw.TextStyle(font: arabicBold, fontSize: 18, color: PdfColors.white),
                textDirection: pw.TextDirection.rtl),
            ],
          ),
        ));

        widgets.add(pw.SizedBox(height: 20));

        // Summary stats
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('F5F0E8'),
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: PdfColor.fromHex('E5D8C8')),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('عدد المعاملات',
                    style: pw.TextStyle(font: arabicFont, fontSize: 12, color: PdfColor.fromHex('9E7B6A')),
                    textDirection: pw.TextDirection.rtl),
                  pw.Text('${session.transactionCount}',
                    style: pw.TextStyle(font: arabicBold, fontSize: 20),
                    textDirection: pw.TextDirection.rtl),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('المجموع العام',
                    style: pw.TextStyle(font: arabicFont, fontSize: 12, color: PdfColor.fromHex('9E7B6A')),
                    textDirection: pw.TextDirection.rtl),
                  pw.Text(formatPrice(session.grandTotal),
                    style: pw.TextStyle(font: arabicBold, fontSize: 22, color: PdfColor.fromHex('5C3317')),
                    textDirection: pw.TextDirection.rtl),
                ],
              ),
            ],
          ),
        ));

        widgets.add(pw.SizedBox(height: 20));

        // Categories
        for (final entry in grouped.entries) {
          final catItems = entry.value;
          final catTotal = catItems.fold(0.0, (s, i) => s + i.total);

          // Group by product
          final Map<String, Map<String, dynamic>> prodGrouped = {};
          for (final item in catItems) {
            if (prodGrouped.containsKey(item.productName)) {
              prodGrouped[item.productName]!['qty'] =
                (prodGrouped[item.productName]!['qty'] as double) + item.quantity;
              prodGrouped[item.productName]!['total'] =
                (prodGrouped[item.productName]!['total'] as double) + item.total;
            } else {
              prodGrouped[item.productName] = {
                'qty': item.quantity, 'price': item.productPrice,
                'unit': item.productUnit, 'total': item.total,
              };
            }
          }

          widgets.add(pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('E5D8C8')),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Category header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('F5F0E8'),
                    borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(10)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(entry.key,
                        style: pw.TextStyle(font: arabicBold, fontSize: 16, color: PdfColor.fromHex('5C3317')),
                        textDirection: pw.TextDirection.rtl),
                      pw.Text(formatPrice(catTotal),
                        style: pw.TextStyle(font: arabicBold, fontSize: 14),
                        textDirection: pw.TextDirection.rtl),
                    ],
                  ),
                ),
                // Table header
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('المنتج',
                        style: pw.TextStyle(font: arabicBold, fontSize: 11, color: PdfColor.fromHex('9E7B6A')),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 60, child: pw.Text('الكمية', textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: arabicBold, fontSize: 11, color: PdfColor.fromHex('9E7B6A')),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 70, child: pw.Text('الثمن', textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: arabicBold, fontSize: 11, color: PdfColor.fromHex('9E7B6A')),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 80, child: pw.Text('المجموع', textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: arabicBold, fontSize: 11, color: PdfColor.fromHex('9E7B6A')),
                        textDirection: pw.TextDirection.rtl)),
                    ],
                  ),
                ),
                pw.Divider(color: PdfColor.fromHex('E5D8C8')),
                ...prodGrouped.entries.map((e) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(e.key,
                        style: pw.TextStyle(font: arabicFont, fontSize: 13),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 60, child: pw.Text(formatQuantity(e.value['qty']),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: arabicFont, fontSize: 13),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 70, child: pw.Text(formatPriceShort(e.value['price']),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(font: arabicFont, fontSize: 13),
                        textDirection: pw.TextDirection.rtl)),
                      pw.SizedBox(width: 80, child: pw.Text(formatPrice(e.value['total']),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: arabicBold, fontSize: 13),
                        textDirection: pw.TextDirection.rtl)),
                    ],
                  ),
                )),
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(12, 6, 12, 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('5C3317').shade(0.08),
                    borderRadius: const pw.BorderRadius.vertical(bottom: pw.Radius.circular(10)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('مجموع الفئة',
                        style: pw.TextStyle(font: arabicBold, fontSize: 13, color: PdfColor.fromHex('5C3317')),
                        textDirection: pw.TextDirection.rtl),
                      pw.Text(formatPrice(catTotal),
                        style: pw.TextStyle(font: arabicBold, fontSize: 14, color: PdfColor.fromHex('5C3317')),
                        textDirection: pw.TextDirection.rtl),
                    ],
                  ),
                ),
              ],
            ),
          ));
          widgets.add(pw.SizedBox(height: 14));
        }

        // Grand total
        widgets.add(pw.Container(
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('5C3317'),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('المجموع العام',
                style: pw.TextStyle(font: arabicBold, fontSize: 20, color: PdfColors.white),
                textDirection: pw.TextDirection.rtl),
              pw.Text(formatPrice(session.grandTotal),
                style: pw.TextStyle(font: arabicBold, fontSize: 24, color: PdfColors.white),
                textDirection: pw.TextDirection.rtl),
            ],
          ),
        ));

        // Footer
        widgets.add(pw.SizedBox(height: 20));
        widgets.add(pw.Center(
          child: pw.Text(
            'تم الإنشاء بواسطة $shopName',
            style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColor.fromHex('9E7B6A')),
            textDirection: pw.TextDirection.rtl,
          ),
        ));

        return widgets;
      },
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'cafe_rays_${session.date}.pdf',
    );
  }
}
