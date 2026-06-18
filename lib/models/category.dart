class Category {
  final int? id;
  final String name;
  final int sortOrder;
  final bool isActive;
  final bool isDynamic; // dynamic categories allow custom product types

  Category({
    this.id,
    required this.name,
    this.sortOrder = 0,
    this.isActive = true,
    this.isDynamic = false,
  });

  Category copyWith({
    int? id,
    String? name,
    int? sortOrder,
    bool? isActive,
    bool? isDynamic,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isDynamic: isDynamic ?? this.isDynamic,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sort_order': sortOrder,
    'is_active': isActive ? 1 : 0,
    'is_dynamic': isDynamic ? 1 : 0,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    sortOrder: map['sort_order'] ?? 0,
    isActive: (map['is_active'] ?? 1) == 1,
    isDynamic: (map['is_dynamic'] ?? 0) == 1,
  );
}
