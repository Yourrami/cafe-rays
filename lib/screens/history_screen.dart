import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'summary_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SalesProvider>().allSessions;
    return Scaffold(
      appBar: AppBar(title: const Text('السجل اليومي')),
      body: sessions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 72, color: AppTheme.textMuted),
                  SizedBox(height: 16),
                  Text('لا توجد سجلات بعد', style: TextStyle(fontSize: 18, color: AppTheme.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (ctx, i) => _SessionTile(session: sessions[i]),
            ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SaleSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final isToday = session.date == todayDateString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppTheme.primary.withOpacity(0.4) : AppTheme.divider,
          width: isToday ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primary : AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isToday ? Icons.today : Icons.calendar_month_outlined,
            color: isToday ? Colors.white : AppTheme.textMuted,
          ),
        ),
        title: Row(
          children: [
            Text(formatDateArabic(session.date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (isToday) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('اليوم', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${session.transactionCount} معاملة',
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        trailing: Text(
          formatPrice(session.grandTotal),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
        ),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SummaryScreen(date: session.date))),
      ),
    );
  }
}
