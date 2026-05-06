import '../models/product.dart';
import '../models/category.dart';
import 'database_service.dart';

/// Service untuk CRUD produk & kategori.
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final DatabaseService _db = DatabaseService();

  // ============================================================
  //  PRODUK — CRUD
  // ============================================================

  /// Ambil semua produk
  Future<List<Product>> getAllProducts() async {
    final maps = await _db.queryAll('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Ambil produk berdasarkan ID
  Future<Product?> getProductById(int id) async {
    final maps = await _db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Ambil produk berdasarkan kategori
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final maps = await _db.query(
      'products',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Cari produk berdasarkan nama (real-time search)
  Future<List<Product>> searchProducts(String query) async {
    final maps = await _db.rawQuery(
      "SELECT * FROM products WHERE name LIKE ? ORDER BY name ASC",
      ['%$query%'],
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  /// Tambah produk baru
  Future<int> addProduct(Product product) async {
    return await _db.insert('products', product.toMap()..remove('id'));
  }

  /// Update produk
  Future<int> updateProduct(Product product) async {
    return await _db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Hapus produk
  Future<int> deleteProduct(int id) async {
    return await _db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Update stok produk (kurangi setelah transaksi)
  Future<void> reduceStock(int productId, int qty) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?',
      [qty, productId, qty],
    );
  }

  // ============================================================
  //  KATEGORI
  // ============================================================

  /// Ambil semua kategori
  Future<List<Category>> getAllCategories() async {
    final maps = await _db.queryAll('categories', orderBy: 'id ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Tambah kategori baru
  Future<int> addCategory(String name) async {
    return await _db.insert('categories', {'name': name});
  }

  /// Update nama kategori
  Future<int> updateCategory(int id, String name) async {
    return await _db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hapus kategori (hanya jika tidak ada produk terkait)
  Future<int> deleteCategory(int id) async {
    return await _db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Hitung jumlah produk di suatu kategori
  Future<int> getProductCountByCategory(int categoryId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE category_id = ?',
      [categoryId],
    );
    return result.first['count'] as int? ?? 0;
  }

  // ============================================================
  //  SEED DATA DUMMY (untuk testing)
  // ============================================================

  /// Cek apakah sudah ada produk, jika belum seed dummy data
  Future<void> seedDummyProducts() async {
    final existing = await getAllProducts();
    if (existing.isNotEmpty) return; // Sudah ada data, skip

    final now = DateTime.now().toIso8601String();

    final dummyProducts = [
      // Makanan (category_id: 1)
      {'name': 'Nasi Goreng', 'category_id': 1, 'price': 15000.0, 'cost_price': 8000.0, 'stock': 50, 'min_stock': 10, 'created_at': now},
      {'name': 'Mie Goreng', 'category_id': 1, 'price': 13000.0, 'cost_price': 7000.0, 'stock': 40, 'min_stock': 10, 'created_at': now},
      {'name': 'Ayam Geprek', 'category_id': 1, 'price': 18000.0, 'cost_price': 10000.0, 'stock': 30, 'min_stock': 5, 'created_at': now},

      // Minuman (category_id: 2)
      {'name': 'Es Teh Manis', 'category_id': 2, 'price': 5000.0, 'cost_price': 2000.0, 'stock': 100, 'min_stock': 20, 'created_at': now},
      {'name': 'Kopi Susu', 'category_id': 2, 'price': 12000.0, 'cost_price': 5000.0, 'stock': 60, 'min_stock': 15, 'created_at': now},
      {'name': 'Jus Jeruk', 'category_id': 2, 'price': 10000.0, 'cost_price': 4000.0, 'stock': 45, 'min_stock': 10, 'created_at': now},

      // Snack (category_id: 3)
      {'name': 'Kentang Goreng', 'category_id': 3, 'price': 15000.0, 'cost_price': 7000.0, 'stock': 35, 'min_stock': 5, 'created_at': now},
      {'name': 'Risol Mayo', 'category_id': 3, 'price': 8000.0, 'cost_price': 4000.0, 'stock': 25, 'min_stock': 5, 'created_at': now},

      // Rokok (category_id: 4)
      {'name': 'Gudang Garam', 'category_id': 4, 'price': 28000.0, 'cost_price': 25000.0, 'stock': 20, 'min_stock': 5, 'created_at': now},

      // Lainnya (category_id: 5)
      {'name': 'Tisu Makan', 'category_id': 5, 'price': 3000.0, 'cost_price': 1500.0, 'stock': 80, 'min_stock': 20, 'created_at': now},
    ];

    for (final product in dummyProducts) {
      await _db.insert('products', product);
    }
  }
}
