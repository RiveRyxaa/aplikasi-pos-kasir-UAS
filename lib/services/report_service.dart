import '../models/transaction.dart';
import 'database_service.dart';

/// Service untuk query data laporan penjualan.
class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final DatabaseService _db = DatabaseService();

  // ============================================================
  //  PENJUALAN HARIAN
  // ============================================================

  /// Ringkasan penjualan hari tertentu
  Future<Map<String, dynamic>> getDailySales(DateTime date) async {
    final dateStr = _formatDate(date);

    final result = await _db.rawQuery('''
      SELECT 
        COUNT(*) as total_transactions,
        COALESCE(SUM(total - discount), 0) as total_revenue,
        COALESCE(SUM(total), 0) as total_before_discount,
        COALESCE(SUM(discount), 0) as total_discount
      FROM transactions
      WHERE DATE(created_at) = ?
    ''', [dateStr]);

    final row = result.first;
    return {
      'totalTransactions': row['total_transactions'] as int? ?? 0,
      'totalRevenue': (row['total_revenue'] as num?)?.toDouble() ?? 0.0,
      'totalBeforeDiscount':
          (row['total_before_discount'] as num?)?.toDouble() ?? 0.0,
      'totalDiscount': (row['total_discount'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // ============================================================
  //  PENJUALAN MINGGUAN (7 hari terakhir)
  // ============================================================

  /// Data penjualan 7 hari terakhir (untuk grafik)
  Future<List<Map<String, dynamic>>> getWeeklySales() async {
    final result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final sales = await getDailySales(date);
      result.add({
        'date': date,
        'label': _getDayLabel(date),
        ...sales,
      });
    }

    return result;
  }

  // ============================================================
  //  PENJUALAN BULANAN (30 hari terakhir)
  // ============================================================

  /// Total penjualan 30 hari terakhir
  Future<Map<String, dynamic>> getMonthlySales() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final fromStr = _formatDate(thirtyDaysAgo);
    final toStr = _formatDate(now);

    final result = await _db.rawQuery('''
      SELECT 
        COUNT(*) as total_transactions,
        COALESCE(SUM(total - discount), 0) as total_revenue,
        COALESCE(SUM(discount), 0) as total_discount
      FROM transactions
      WHERE DATE(created_at) >= ? AND DATE(created_at) <= ?
    ''', [fromStr, toStr]);

    final row = result.first;
    return {
      'totalTransactions': row['total_transactions'] as int? ?? 0,
      'totalRevenue': (row['total_revenue'] as num?)?.toDouble() ?? 0.0,
      'totalDiscount': (row['total_discount'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // ============================================================
  //  RIWAYAT TRANSAKSI
  // ============================================================

  /// Ambil transaksi berdasarkan range tanggal
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final fromStr = _formatDate(from);
    final toStr = _formatDate(to);

    final maps = await _db.rawQuery('''
      SELECT * FROM transactions
      WHERE DATE(created_at) >= ? AND DATE(created_at) <= ?
      ORDER BY created_at DESC
    ''', [fromStr, toStr]);

    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  /// Ambil transaksi berdasarkan metode bayar
  Future<List<Transaction>> getTransactionsByPaymentMethod(
    String method,
  ) async {
    final maps = await _db.rawQuery('''
      SELECT * FROM transactions
      WHERE payment_method = ?
      ORDER BY created_at DESC
    ''', [method]);

    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  /// Ambil transaksi hari ini
  Future<List<Transaction>> getTodayTransactions() async {
    final today = DateTime.now();
    return getTransactionsByDateRange(today, today);
  }

  // ============================================================
  //  PRODUK TERLARIS
  // ============================================================

  /// Ranking produk terlaris berdasarkan qty terjual
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 10}) async {
    final result = await _db.rawQuery('''
      SELECT 
        ti.product_name,
        ti.product_id,
        SUM(ti.qty) as total_qty,
        SUM(ti.subtotal) as total_revenue
      FROM transaction_items ti
      GROUP BY ti.product_id, ti.product_name
      ORDER BY total_qty DESC
      LIMIT ?
    ''', [limit]);

    return result.map((row) {
      return {
        'productName': row['product_name'] as String? ?? '-',
        'productId': row['product_id'] as int?,
        'totalQty': row['total_qty'] as int? ?? 0,
        'totalRevenue': (row['total_revenue'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // ============================================================
  //  RINGKASAN PER METODE BAYAR
  // ============================================================

  /// Breakdown pendapatan per metode bayar hari ini
  Future<List<Map<String, dynamic>>> getTodayPaymentBreakdown() async {
    final today = _formatDate(DateTime.now());

    final result = await _db.rawQuery('''
      SELECT 
        payment_method,
        COUNT(*) as count,
        COALESCE(SUM(total - discount), 0) as total
      FROM transactions
      WHERE DATE(created_at) = ?
      GROUP BY payment_method
    ''', [today]);

    return result.map((row) {
      return {
        'method': row['payment_method'] as String? ?? '-',
        'count': row['count'] as int? ?? 0,
        'total': (row['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // ============================================================
  //  HELPERS
  // ============================================================

  /// Format date ke string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Label hari singkat (Sen, Sel, Rab, dll)
  String _getDayLabel(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }
}
