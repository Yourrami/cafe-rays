import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/settings.dart';
import 'database_service.dart';

class SalesProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Category> _categories = [];
  Map<int, List<Product>> _productsByCategory = {};
  List<CartItem> _cart = [];
  SaleSession? _todaySession;
  List<SaleItem> _todayItems = [];
  List<SaleSession> _allSessions = [];
  AppSettings _settings = AppSettings();
  bool _isLoading = false;
  SaleItem? _lastDeletedItem;

  List<Category> get categories => _categories;
  Map<int, List<Product>> get productsByCategory => _productsByCategory;
  List<CartItem> get cart => _cart;
  SaleSession? get todaySession => _todaySession;
  List<SaleItem> get todayItems => _todayItems;
  List<SaleSession> get allSessions => _allSessions;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  SaleItem? get lastDeletedItem => _lastDeletedItem;

  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.total);
  int get cartItemCount => _cart.fold(0, (sum, item) => sum + item.quantity.toInt());

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _loadSettings();
    await _loadCategories();
    await _loadTodaySession();
    await _loadAllSessions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    _settings = await _db.getSettings();
  }

  Future<void> _loadCategories() async {
    _categories = await _db.getCategories(activeOnly: true);
    _productsByCategory = {};
    for (final cat in _categories) {
      if (cat.id != null) {
        _productsByCategory[cat.id!] = await _db.getProductsByCategory(cat.id!, activeOnly: true);
      }
    }
  }

  Future<void> _loadTodaySession() async {
    _todaySession = await _db.getOrCreateTodaySession();
    if (_todaySession?.id != null) {
      _todayItems = await _db.getSaleItemsBySession(_todaySession!.id!);
    }
  }

  Future<void> _loadAllSessions() async {
    _allSessions = await _db.getAllSessions();
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────
  void addToCart(Product product) {
    final existing = _cart.where((c) => c.productId == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      _cart.add(CartItem(
        productId: product.id!,
        productName: product.name,
        productPrice: product.price,
        productUnit: product.unit,
        categoryId: product.categoryId,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final existing = _cart.where((c) => c.productId == product.id).firstOrNull;
    if (existing != null) {
      if (existing.quantity > 1) {
        existing.quantity--;
      } else {
        _cart.remove(existing);
      }
    }
    notifyListeners();
  }

  void addToCartById(int productId, {double quantity = 1.0}) {
    for (final catProducts in _productsByCategory.values) {
      for (final p in catProducts) {
        if (p.id == productId) {
          final existing = _cart.where((c) => c.productId == productId).firstOrNull;
          if (existing != null) {
            existing.quantity += quantity;
          } else {
            _cart.add(CartItem(
              productId: p.id!,
              productName: p.name,
              productPrice: p.price,
              productUnit: p.unit,
              categoryId: p.categoryId,
              quantity: quantity,
            ));
          }
          notifyListeners();
          return;
        }
      }
    }
  }

  double getCartQuantity(int productId) {
    return _cart.where((c) => c.productId == productId).firstOrNull?.quantity ?? 0;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ─── Confirm Sale ─────────────────────────────────────────────────────────
  Future<bool> confirmSale() async {
    if (_cart.isEmpty) return false;
    try {
      _todaySession ??= await _db.getOrCreateTodaySession();
      final sessionId = _todaySession!.id!;
      final now = DateTime.now();
      for (final item in _cart) {
        await _db.insertSaleItem(SaleItem(
          saleSessionId: sessionId,
          productId: item.productId,
          productName: item.productName,
          productPrice: item.productPrice,
          productUnit: item.productUnit,
          quantity: item.quantity,
          total: item.total,
          createdAt: now,
        ));
      }
      _cart.clear();
      await _loadTodaySession();
      await _loadAllSessions();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Delete Sale Item with Undo ───────────────────────────────────────────
  Future<void> deleteSaleItem(SaleItem item) async {
    _lastDeletedItem = item;
    await _db.deleteSaleItem(item.id!, item.saleSessionId);
    await _loadTodaySession();
    await _loadAllSessions();
    notifyListeners();
  }

  Future<void> undoDeleteSaleItem() async {
    if (_lastDeletedItem == null) return;
    await _db.insertSaleItem(_lastDeletedItem!);
    _lastDeletedItem = null;
    await _loadTodaySession();
    await _loadAllSessions();
    notifyListeners();
  }

  // ─── Categories Management ────────────────────────────────────────────────
  Future<void> addCategory(Category cat) async {
    await _db.insertCategory(cat);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category cat) async {
    await _db.updateCategory(cat);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await _loadCategories();
    notifyListeners();
  }

  // ─── Products Management ──────────────────────────────────────────────────
  Future<List<Product>> getAllProductsForCategory(int categoryId) async {
    return await _db.getProductsByCategory(categoryId);
  }

  Future<void> addProduct(Product product) async {
    await _db.insertProduct(product);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _db.updateProduct(product);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> softDeleteProduct(int id) async {
    await _db.softDeleteProduct(id);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> restoreProduct(int id) async {
    await _db.restoreProduct(id);
    await _loadCategories();
    notifyListeners();
  }

  Future<void> reorderProducts(List<Product> products) async {
    await _db.reorderProducts(products);
    await _loadCategories();
    notifyListeners();
  }

  // ─── Session Data ─────────────────────────────────────────────────────────
  Future<List<SaleItem>> getItemsForSession(int sessionId) async {
    return await _db.getSaleItemsBySession(sessionId);
  }

  Future<SaleSession?> getSessionByDate(String date) async {
    return await _db.getSessionByDate(date);
  }

  // ─── Settings ─────────────────────────────────────────────────────────────
  Future<void> saveSettings(AppSettings settings) async {
    await _db.saveSettings(settings);
    _settings = settings;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await initialize();
  }
}
