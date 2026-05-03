import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Utility untuk format tanggal & waktu Indonesia.
class DateFormatter {
  DateFormatter._();

  static bool _initialized = false;

  /// Inisialisasi locale Indonesia (panggil sekali di main)
  static Future<void> init() async {
    if (!_initialized) {
      await initializeDateFormatting('id_ID', null);
      _initialized = true;
    }
  }

  /// Format tanggal lengkap
  /// Contoh: "Jumat, 2 Mei 2026"
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal pendek
  /// Contoh: "2 Mei 2026"
  static String formatShort(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal angka
  /// Contoh: "02/05/2026"
  static String formatNumeric(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format waktu
  /// Contoh: "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format tanggal + waktu
  /// Contoh: "2 Mei 2026, 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Format relatif ("Hari ini", "Kemarin", atau tanggal)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff < 7) return '$diff hari lalu';
    return formatShort(date);
  }

  /// Parse ISO string ke DateTime
  static DateTime? parse(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }
}
