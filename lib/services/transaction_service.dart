import '../models/transaction.dart';
import '../models/transaction_item.dart';
import '../services/database_service.dart';
import '../services/product_service.dart';

/// Service untuk membuat & mengelola transaksi.
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final DatabaseService _db = DatabaseService();
  final ProductService _productService = ProductService();

  // ============================================================
  //  BUAT TRANSAKSI
  // ============================================================

  /// Buat transaksi baru, simpan items, dan kurangi stok produk.
  /// Returns ID transaksi yang baru dibuat.
  Future<int> createTransaction({
    required double total,
    required double discount,
    required String paymentMethod,
    required double amountPaid,
    required double changeAmount,
    required List<TransactionItem> items,
  }) async {
    final db = await _db.database;

    // Generate nomor invoice
    final invoiceNumber = await generateInvoiceNumber();

    // Simpan transaksi
    final transactionId = await db.insert('transactions', {
      'invoice_number': invoiceNumber,
      'total': total,
      'discount': discount,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Simpan item transaksi & kurangi stok
    for (final item in items) {
      await db.insert('transaction_items', {
        'transaction_id': transactionId,
        'product_id': item.productId,
        'product_name': item.productName,
        'price': item.price,
        'qty': item.qty,
        'subtotal': item.subtotal,
      });

      // Kurangi stok produk
      if (item.productId != null) {
        await _productService.reduceStock(item.productId!, item.qty);
      }
    }

    return transactionId;
  }

  // ============================================================
  //  AMBIL TRANSAKSI
  // ============================================================

  /// Ambil transaksi berdasarkan ID
  Future<Transaction?> getTransactionById(int id) async {
    final maps = await _db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  /// Ambil transaksi berdasarkan invoice number
  Future<Transaction?> getTransactionByInvoice(String invoiceNumber) async {
    final maps = await _db.query(
      'transactions',
      where: 'invoice_number = ?',
      whereArgs: [invoiceNumber],
    );
    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  /// Ambil items dari transaksi
  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final maps = await _db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return maps.map((m) => TransactionItem.fromMap(m)).toList();
  }

  /// Ambil semua transaksi (terbaru dulu)
  Future<List<Transaction>> getAllTransactions() async {
    final maps = await _db.queryAll('transactions', orderBy: 'created_at DESC');
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  // ============================================================
  //  GENERATE INVOICE NUMBER
  // ============================================================

  /// Generate nomor invoice unik: INV-20260503-001
  Future<String> generateInvoiceNumber() async {
    final today = DateTime.now();
    final dateStr = '${today.year}'
        '${today.month.toString().padLeft(2, '0')}'
        '${today.day.toString().padLeft(2, '0')}';

    // Hitung jumlah transaksi hari ini
    final prefix = 'INV-$dateStr-';
    final result = await _db.rawQuery(
      "SELECT COUNT(*) as count FROM transactions WHERE invoice_number LIKE ?",
      ['$prefix%'],
    );
    final count = (result.first['count'] as int? ?? 0) + 1;

    return '$prefix${count.toString().padLeft(3, '0')}';
  }
}
