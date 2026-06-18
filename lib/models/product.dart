class Product {
  final int? id;
  final int categoryId;
  final String name;
  final double price;
  final String unit; // درهم / كيلوغرام / غرام / قطعة / علبة / قنينة
  final String? notes;
  final int sortOrder;
  final bool isActive;
  final bool isDeleted;

  Product({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.unit = 'وحدة',
    this.notes,
    this.sortOrder = 0,
    this.isActive = true,
    this.isDeleted = false,
  });

  Product copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? price,
    String? unit,
    String? notes,
    int? sortOrder,
    bool? isActive,
    bool? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'price': price,
    'unit': unit,
    'notes': notes,
    'sort_order': sortOrder,
    'is_active': isActive ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'],
    categoryId: map['category_id'],
    name: map['name'],
    price: (map['price'] as num).toDouble(),
    unit: map['unit'] ?? 'وحدة',
    notes: map['notes'],
    sortOrder: map['sort_order'] ?? 0,
    isActive: (map['is_active'] ?? 1) == 1,
    isDeleted: (map['is_deleted'] ?? 0) == 1,
  );
}
