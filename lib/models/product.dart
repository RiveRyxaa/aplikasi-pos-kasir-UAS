/// Model Produk.
/// Tabel: products (SQLite)
class Product {
  final int? id;
  final String name;
  final int? categoryId;
  final double price;
  final double? costPrice;
  final int stock;
  final int minStock;
  final String? barcode;
  final String? imagePath;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    this.categoryId,
    required this.price,
    this.costPrice,
    this.stock = 0,
    this.minStock = 5,
    this.barcode,
    this.imagePath,
    this.createdAt,
  });

  /// Konversi dari Map (SQLite row) ke Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int?,
      price: (map['price'] as num).toDouble(),
      costPrice: map['cost_price'] != null
          ? (map['cost_price'] as num).toDouble()
          : null,
      stock: map['stock'] as int? ?? 0,
      minStock: map['min_stock'] as int? ?? 5,
      barcode: map['barcode'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Konversi ke Map untuk insert/update SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'cost_price': costPrice,
      'stock': stock,
      'min_stock': minStock,
      'barcode': barcode,
      'image_path': imagePath,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  /// Cek apakah stok menipis (di bawah batas minimum)
  bool get isLowStock => stock <= minStock;

  /// Copy with
  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? price,
    double? costPrice,
    int? stock,
    int? minStock,
    String? barcode,
    String? imagePath,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      barcode: barcode ?? this.barcode,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
