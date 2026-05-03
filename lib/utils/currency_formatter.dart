import 'package:intl/intl.dart';

/// Utility untuk format mata uang Rupiah.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _formatterDecimal = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka ke Rupiah tanpa desimal
  /// Contoh: 50000 → "Rp 50.000"
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format angka ke Rupiah dengan desimal
  /// Contoh: 50000.50 → "Rp 50.000,50"
  static String formatDecimal(double amount) {
    return _formatterDecimal.format(amount);
  }

  /// Format compact (singkat)
  /// Contoh: 1500000 → "Rp 1,5 jt"
  static String formatCompact(double amount) {
    return _compactFormatter.format(amount);
  }

  /// Format angka biasa dengan separator ribuan
  /// Contoh: 50000 → "50.000"
  static String formatNumber(double amount) {
    return NumberFormat('#,##0', 'id_ID').format(amount);
  }

  /// Parse string Rupiah ke double
  /// Contoh: "Rp 50.000" → 50000.0
  static double parse(String formatted) {
    try {
      final cleaned = formatted
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (_) {
      return 0.0;
    }
  }
}
