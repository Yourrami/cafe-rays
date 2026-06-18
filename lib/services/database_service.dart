import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/settings.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cafe_rays.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        is_dynamic INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT DEFAULT 'وحدة',
        notes TEXT,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        is_deleted INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        grand_total REAL DEFAULT 0,
        transaction_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_session_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_price REAL NOT NULL,
        product_unit TEXT DEFAULT 'وحدة',
        quantity REAL NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sale_session_id) REFERENCES sale_sessions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY DEFAULT 1,
        shop_name TEXT DEFAULT 'Café Rays',
        pin TEXT,
        pin_enabled INTEGER DEFAULT 0
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Insert default settings
    await db.insert('app_settings', {
      'id': 1,
      'shop_name': 'Café Rays',
      'pin': null,
      'pin_enabled': 0,
    });

    // Insert categories
    final cat1 = await db.insert('categories', {
      'name': 'قهوة',
      'sort_order': 0,
      'is_active': 1,
      'is_dynamic': 0,
    });
    final cat2 = await db.insert('categories', {
      'name': 'قهوة مطحونة',
      'sort_order': 1,
      'is_active': 1,
      'is_dynamic': 1,
    });
    final cat3 = await db.insert('categories', {
      'name': 'الشاي',
      'sort_order': 2,
      'is_active': 1,
      'is_dynamic': 1,
    });
    final cat4 = await db.insert('categories', {
      'name': 'العسل',
      'sort_order': 3,
      'is_active': 1,
      'is_dynamic': 1,
    });

    // Insert coffee products
    final coffeeProducts = [
      {'name': 'قهوة نورمال', 'price': 7.0},
      {'name': 'قهوة بالزعتر', 'price': 8.0},
      {'name': 'قهوة بالعسل', 'price': 9.0},
      {'name': 'قهوة بالحليب', 'price': 8.0},
      {'name': 'كابوشينو', 'price': 8.0},
      {'name': 'حليب بالشكلاط', 'price': 7.0},
      {'name': 'ماء 33cl', 'price': 2.0},
      {'name': 'ماء 0.5L', 'price': 3.0},
      {'name': 'ماء 1.5L', 'price': 5.0},
    ];

    for (var i = 0; i < coffeeProducts.length; i++) {
      await db.insert('products', {
        'category_id': cat1,
        'name': coffeeProducts[i]['name'],
        'price': coffeeProducts[i]['price'],
        'unit': 'فنجان',
        'sort_order': i,
        'is_active': 1,
        'is_deleted': 0,
      });
    }

    // Seed example ground coffee
    await db.insert('products', {
      'category_id': cat2,
      'name': 'قهوة عربية',
      'price': 80.0,
      'unit': 'كيلوغرام',
      'sort_order': 0,
      'is_active': 1,
      'is_deleted': 0,
    });
    await db.insert('products', {
      'category_id': cat2,
      'name': 'قهوة تركية',
      'price': 90.0,
      'unit': 'كيلوغرام',
      'sort_order': 1,
      'is_active': 1,
      'is_deleted': 0,
    });

    // Seed example tea
    await db.insert('products', {
      'category_id': cat3,
      'name': 'شاي أخضر',
      'price': 60.0,
      'unit': 'كيلوغرام',
      'sort_order': 0,
      'is_active': 1,
      'is_deleted': 0,
    });
    await db.insert('products', {
      'category_id': cat3,
      'name': 'شاي أحمر',
      'price': 50.0,
      'unit': 'كيلوغرام',
      'sort_order': 1,
      'is_active': 1,
      'is_deleted': 0,
    });

    // Seed example honey
    await db.insert('products', {
      'category_id': cat4,
      'name': 'عسل طبيعي',
      'price': 150.0,
      'unit': 'كيلوغرام',
      'sort_order': 0,
      'is_active': 1,
      'is_deleted': 0,
    });
  }

  // ─── Categories ───────────────────────────────────────────────────────────
  Future<List<Category>> getCategories({bool activeOnly = false}) async {
    final db = await database;
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('categories', where: where, orderBy: 'sort_order ASC');
    return maps.map(Category.fromMap).toList();
  }

  Future<int> insertCategory(Category cat) async {
    final db = await database;
    return await db.insert('categories', cat.toMap()..remove('id'));
  }

  Future<void> updateCategory(Category cat) async {
    final db = await database;
    await db.update('categories', cat.toMap(), where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorderCategories(List<Category> categories) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < categories.length; i++) {
      batch.update('categories', {'sort_order': i}, where: 'id = ?', whereArgs: [categories[i].id]);
    }
    await batch.commit(noResult: true);
  }

  // ─── Products ─────────────────────────────────────────────────────────────
  Future<List<Product>> getProductsByCategory(int categoryId, {bool activeOnly = false}) async {
    final db = await database;
    String where = 'category_id = ? AND is_deleted = 0';
    if (activeOnly) where += ' AND is_active = 1';
    final maps = await db.query('products', where: where, whereArgs: [categoryId], orderBy: 'sort_order ASC');
    return maps.map(Product.fromMap).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final map = product.toMap()..remove('id');
    return await db.insert('products', map);
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> softDeleteProduct(int id) async {
    final db = await database;
    await db.update('products', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restoreProduct(int id) async {
    final db = await database;
    await db.update('products', {'is_deleted': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reorderProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < products.length; i++) {
      batch.update('products', {'sort_order': i}, where: 'id = ?', whereArgs: [products[i].id]);
    }
    await batch.commit(noResult: true);
  }

  // ─── Sale Sessions ─────────────────────────────────────────────────────────
  Future<SaleSession> getOrCreateTodaySession() async {
    final db = await database;
    final today = _dateString(DateTime.now());
    final existing = await db.query('sale_sessions', where: 'date = ?', whereArgs: [today]);
    if (existing.isNotEmpty) return SaleSession.fromMap(existing.first);
    final now = DateTime.now();
    final id = await db.insert('sale_sessions', {
      'date': today,
      'grand_total': 0.0,
      'transaction_count': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    return SaleSession(id: id, date: today, createdAt: now, updatedAt: now);
  }

  Future<List<SaleSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('sale_sessions', orderBy: 'date DESC');
    return maps.map(SaleSession.fromMap).toList();
  }

  Future<SaleSession?> getSessionByDate(String date) async {
    final db = await database;
    final maps = await db.query('sale_sessions', where: 'date = ?', whereArgs: [date]);
    if (maps.isEmpty) return null;
    return SaleSession.fromMap(maps.first);
  }

  Future<void> _updateSessionTotals(int sessionId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total),0) as grand_total, COUNT(*) as cnt FROM sale_items WHERE sale_session_id = ?',
      [sessionId],
    );
    final grandTotal = (result.first['grand_total'] as num).toDouble();
    final cnt = result.first['cnt'] as int;
    await db.update('sale_sessions', {
      'grand_total': grandTotal,
      'transaction_count': cnt,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [sessionId]);
  }

  // ─── Sale Items ────────────────────────────────────────────────────────────
  Future<int> insertSaleItem(SaleItem item) async {
    final db = await database;
    final id = await db.insert('sale_items', item.toMap()..remove('id'));
    await _updateSessionTotals(item.saleSessionId);
    return id;
  }

  Future<void> deleteSaleItem(int id, int sessionId) async {
    final db = await database;
    await db.delete('sale_items', where: 'id = ?', whereArgs: [id]);
    await _updateSessionTotals(sessionId);
  }

  Future<List<SaleItem>> getSaleItemsBySession(int sessionId) async {
    final db = await database;
    final maps = await db.query('sale_items', where: 'sale_session_id = ?', whereArgs: [sessionId], orderBy: 'created_at ASC');
    return maps.map(SaleItem.fromMap).toList();
  }

  Future<List<SaleItem>> getLatestSaleItems(int sessionId, {int limit = 10}) async {
    final db = await database;
    final maps = await db.query('sale_items',
      where: 'sale_session_id = ?', whereArgs: [sessionId],
      orderBy: 'created_at DESC', limit: limit);
    return maps.map(SaleItem.fromMap).toList();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────
  Future<AppSettings> getSettings() async {
    final db = await database;
    final maps = await db.query('app_settings', where: 'id = 1');
    if (maps.isEmpty) return AppSettings();
    return AppSettings.fromMap(maps.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.update('app_settings', settings.toMap(), where: 'id = 1');
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _dateString(DateTime dt) =>
    '${dt.year.toString().padLeft(4,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
