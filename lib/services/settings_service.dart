import 'database_service.dart';

/// Service untuk kelola pengaturan toko (key-value di SQLite).
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final DatabaseService _db = DatabaseService();

  // Keys
  static const String keyStoreName = 'store_name';
  static const String keyStoreAddress = 'store_address';
  static const String keyStorePhone = 'store_phone';
  static const String keyReceiptFooter = 'receipt_footer';
  static const String keyShowCostPrice = 'show_cost_price';

  // ============================================================
  //  GET / SET
  // ============================================================

  /// Ambil satu nilai setting
  Future<String?> getValue(String key) async {
    final maps = await _db.query(
      'store_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  /// Simpan satu nilai setting (insert or update)
  Future<void> setValue(String key, String value) async {
    final db = await _db.database;
    await db.rawInsert('''
      INSERT OR REPLACE INTO store_settings (key, value) VALUES (?, ?)
    ''', [key, value]);
  }

  // ============================================================
  //  PROFIL TOKO
  // ============================================================

  /// Ambil semua pengaturan toko sekaligus
  Future<Map<String, String>> getStoreProfile() async {
    return {
      'storeName': await getValue(keyStoreName) ?? 'Toko Saya',
      'storeAddress': await getValue(keyStoreAddress) ?? '',
      'storePhone': await getValue(keyStorePhone) ?? '',
    };
  }

  /// Simpan profil toko
  Future<void> updateStoreProfile({
    required String storeName,
    required String storeAddress,
    required String storePhone,
  }) async {
    await setValue(keyStoreName, storeName);
    await setValue(keyStoreAddress, storeAddress);
    await setValue(keyStorePhone, storePhone);
  }

  // ============================================================
  //  PENGATURAN STRUK
  // ============================================================

  /// Ambil pesan footer struk
  Future<String> getReceiptFooter() async {
    return await getValue(keyReceiptFooter) ??
        'Terima kasih atas kunjungan Anda!';
  }

  /// Simpan pesan footer struk
  Future<void> setReceiptFooter(String footer) async {
    await setValue(keyReceiptFooter, footer);
  }

  /// Cek apakah harga beli tampil di struk
  Future<bool> getShowCostPrice() async {
    final val = await getValue(keyShowCostPrice);
    return val == 'true';
  }

  /// Set toggle harga beli di struk
  Future<void> setShowCostPrice(bool show) async {
    await setValue(keyShowCostPrice, show.toString());
  }

  // ============================================================
  //  SEED DEFAULT (dipanggil saat pertama kali)
  // ============================================================

  /// Insert default settings jika belum ada
  Future<void> seedDefaults() async {
    final existing = await getValue(keyStoreName);
    if (existing != null) return; // Sudah ada, skip

    await setValue(keyStoreName, 'Toko Saya');
    await setValue(keyStoreAddress, '');
    await setValue(keyStorePhone, '');
    await setValue(keyReceiptFooter, 'Terima kasih atas kunjungan Anda!');
    await setValue(keyShowCostPrice, 'false');
  }
}
