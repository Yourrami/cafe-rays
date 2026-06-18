class SaleItem {
  final int? id;
  final int saleSessionId;
  final int productId;
  final String productName;
  final double productPrice;
  final String productUnit;
  final double quantity;
  final double total;
  final DateTime createdAt;

  SaleItem({
    this.id,
    required this.saleSessionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productUnit,
    required this.quantity,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'sale_session_id': saleSessionId,
    'product_id': productId,
    'product_name': productName,
    'product_price': productPrice,
    'product_unit': productUnit,
    'quantity': quantity,
    'total': total,
    'created_at': createdAt.toIso8601String(),
  };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
    id: map['id'],
    saleSessionId: map['sale_session_id'],
    productId: map['product_id'],
    productName: map['product_name'],
    productPrice: (map['product_price'] as num).toDouble(),
    productUnit: map['product_unit'] ?? 'وحدة',
    quantity: (map['quantity'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
    createdAt: DateTime.parse(map['created_at']),
  );
}

class SaleSession {
  final int? id;
  final String date; // YYYY-MM-DD
  final double grandTotal;
  final int transactionCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleSession({
    this.id,
    required this.date,
    this.grandTotal = 0,
    this.transactionCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'grand_total': grandTotal,
    'transaction_count': transactionCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory SaleSession.fromMap(Map<String, dynamic> map) => SaleSession(
    id: map['id'],
    date: map['date'],
    grandTotal: (map['grand_total'] as num).toDouble(),
    transactionCount: map['transaction_count'] ?? 0,
    createdAt: DateTime.parse(map['created_at']),
    updatedAt: DateTime.parse(map['updated_at']),
  );
}

class CartItem {
  final int productId;
  final String productName;
  final double productPrice;
  final String productUnit;
  final int categoryId;
  double quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productUnit,
    required this.categoryId,
    this.quantity = 1,
  });

  double get total => quantity * productPrice;
}
