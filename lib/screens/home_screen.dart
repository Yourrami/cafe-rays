import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'sales_screen.dart';
import 'summary_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    SalesScreen(),
    SummaryScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  final _titles = ['البيع السريع', 'ملخص اليوم', 'السجل اليومي', 'الإعدادات'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee, size: 24),
            const SizedBox(width: 8),
            Text(_titles[_currentIndex]),
          ],
        ),
        actions: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    formatDateArabic(todayDateString()),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: provider.cartItemCount > 0,
              label: Text('${provider.cartItemCount}'),
              child: const Icon(Icons.point_of_sale_outlined),
            ),
            activeIcon: const Icon(Icons.point_of_sale),
            label: 'البيع',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'الملخص',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'السجل',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
