import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../services/sales_provider.dart';
import '../utils/theme.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shopNameCtrl;
  bool _pinEnabled = false;
  String? _pin;
  bool _showPin = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SalesProvider>().settings;
    _shopNameCtrl = TextEditingController(text: settings.shopName);
    _pinEnabled = settings.pinEnabled;
    _pin = settings.pin;
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader('معلومات المحل'),
          const SizedBox(height: 12),
          TextField(
            controller: _shopNameCtrl,
            decoration: const InputDecoration(labelText: 'اسم المحل', prefixIcon: Icon(Icons.store_outlined)),
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 24),
          _sectionHeader('إدارة الفئات والمنتجات'),
          const SizedBox(height: 12),
          _settingsTile(
            icon: Icons.category_outlined,
            title: 'إدارة الفئات والأنواع',
            subtitle: 'إضافة وتعديل الفئات والمنتجات',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())),
          ),
          const SizedBox(height: 24),
          _sectionHeader('الأمان'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تفعيل رمز PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Switch(
                      value: _pinEnabled,
                      onChanged: (v) => setState(() => _pinEnabled = v),
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
                if (_pinEnabled) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    obscureText: !_showPin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'رمز PIN',
                      hintText: '4-6 أرقام',
                      suffixIcon: IconButton(
                        icon: Icon(_showPin ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPin = !_showPin),
                      ),
                    ),
                    onChanged: (v) => _pin = v,
                    controller: TextEditingController(text: _pin),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('حفظ الإعدادات'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5),
  );

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final settings = AppSettings(
      shopName: _shopNameCtrl.text.trim().isEmpty ? 'Café Rays' : _shopNameCtrl.text.trim(),
      pin: _pinEnabled ? _pin : null,
      pinEnabled: _pinEnabled,
    );
    await context.read<SalesProvider>().saveSettings(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم حفظ الإعدادات'), backgroundColor: AppTheme.success),
      );
    }
  }
}
