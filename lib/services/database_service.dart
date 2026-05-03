import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service database SQLite untuk CRUD produk, transaksi, kategori.
/// Singleton pattern — satu instance dipakai di seluruh app.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  /// Ambil instance database (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kasir.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Buat semua tabel saat database pertama kali dibuat
  Future<void> _createTables(Database db, int version) async {
    // Tabel Kategori
    await db.execute('''
      CREATE TABLE categories (
        id    INTEGER PRIMARY KEY AUTOINCREMENT,
        name  TEXT NOT NULL
      )
    ''');

    // Tabel Produk
    await db.execute('''
      CREATE TABLE products (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT NOT NULL,
        category_id INTEGER,
        price       REAL NOT NULL,
        cost_price  REAL,
        stock       INTEGER DEFAULT 0,
        min_stock   INTEGER DEFAULT 5,
        barcode     TEXT,
        image_path  TEXT,
        created_at  TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE transactions (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT UNIQUE,
        total          REAL NOT NULL,
        discount       REAL DEFAULT 0,
        payment_method TEXT,
        amount_paid    REAL,
        change_amount  REAL,
        created_at     TEXT
      )
    ''');

    // Tabel Item Transaksi
    await db.execute('''
      CREATE TABLE transaction_items (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        product_id     INTEGER,
        product_name   TEXT,
        price          REAL,
        qty            INTEGER,
        subtotal       REAL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Tabel Pengaturan Toko
    await db.execute('''
      CREATE TABLE store_settings (
        key   TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Insert kategori default
    await db.insert('categories', {'name': 'Makanan'});
    await db.insert('categories', {'name': 'Minuman'});
    await db.insert('categories', {'name': 'Snack'});
    await db.insert('categories', {'name': 'Rokok'});
    await db.insert('categories', {'name': 'Lainnya'});
  }

  // ============================================================
  //  DASHBOARD — Ringkasan Hari Ini
  // ============================================================

  /// Ambil ringkasan penjualan hari ini
  Future<Map<String, dynamic>> getDailySummary() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    // Total transaksi hari ini
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM transactions
      WHERE created_at LIKE '$today%'
    ''');
    final totalTransactions = countResult.first['count'] as int? ?? 0;

    // Total pendapatan hari ini
    final revenueResult = await db.rawQuery('''
      SELECT COALESCE(SUM(total - discount), 0) as revenue FROM transactions
      WHERE created_at LIKE '$today%'
    ''');
    final totalRevenue = (revenueResult.first['revenue'] as num?)?.toDouble() ?? 0.0;

    // Jumlah item terjual hari ini
    final itemsResult = await db.rawQuery('''
      SELECT COALESCE(SUM(ti.qty), 0) as items
      FROM transaction_items ti
      INNER JOIN transactions t ON ti.transaction_id = t.id
      WHERE t.created_at LIKE '$today%'
    ''');
    final totalItems = itemsResult.first['items'] as int? ?? 0;

    return {
      'totalTransactions': totalTransactions,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
    };
  }

  // ============================================================
  //  GENERIC CRUD HELPERS
  // ============================================================

  /// Insert row ke tabel
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Update row di tabel
  Future<int> update(String table, Map<String, dynamic> data,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Delete row dari tabel
  Future<int> delete(String table,
      {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Query semua row dari tabel
  Future<List<Map<String, dynamic>>> queryAll(String table,
      {String? orderBy}) async {
    final db = await database;
    return await db.query(table, orderBy: orderBy);
  }

  /// Query dengan kondisi
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  /// Raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
