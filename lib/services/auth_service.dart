import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/constants.dart';

/// Service untuk autentikasi lokal.
/// Menggunakan Hive untuk data user & SharedPreferences untuk sesi.
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Box Hive untuk menyimpan data user
  Box<User> get _userBox => Hive.box<User>(AppStrings.userBox);

  /// Box Hive untuk menyimpan sesi login
  Box get _sessionBox => Hive.box(AppStrings.sessionBox);

  // ============================================================
  //  REGISTER
  // ============================================================

  /// Daftarkan user baru.
  /// Returns [User] jika berhasil, throw [Exception] jika gagal.
  Future<User> register({
    required String storeName,
    required String ownerName,
    required String phone,
    required String password,
  }) async {
    // Cek apakah nomor HP sudah terdaftar
    final existingUser = _findUserByPhone(phone);
    if (existingUser != null) {
      throw Exception('Nomor HP sudah terdaftar');
    }

    // Buat user baru
    final user = User.create(
      storeName: storeName,
      ownerName: ownerName,
      phone: phone,
      password: password,
    );

    // Simpan ke Hive
    await _userBox.put(user.id, user);

    return user;
  }

  // ============================================================
  //  LOGIN
  // ============================================================

  /// Login dengan nomor HP dan password.
  /// Returns [User] jika berhasil, throw [Exception] jika gagal.
  Future<User> login({
    required String phone,
    required String password,
    bool rememberMe = false,
  }) async {
    // Cari user berdasarkan nomor HP
    final user = _findUserByPhone(phone);

    if (user == null) {
      throw Exception('Akun tidak ditemukan');
    }

    // Verifikasi password
    if (user.password != password) {
      throw Exception('Password salah');
    }

    // Simpan sesi login
    await _saveSession(user.id);

    // Simpan flag "Ingat Saya"
    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStrings.rememberMeKey, true);
    }

    return user;
  }

  // ============================================================
  //  SESI & STATUS LOGIN
  // ============================================================

  /// Cek apakah user sedang login (ada sesi aktif).
  Future<bool> isLoggedIn() async {
    final userId = _sessionBox.get(AppStrings.sessionKey);
    if (userId == null) return false;

    // Cek flag "Ingat Saya"
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppStrings.rememberMeKey) ?? false;

    // Jika tidak centang "Ingat Saya", hapus sesi
    if (!rememberMe) {
      return false;
    }

    // Pastikan user masih ada di database
    final user = _userBox.get(userId);
    return user != null;
  }

  /// Ambil data user yang sedang login.
  /// Returns [User] jika ada sesi aktif, null jika tidak.
  User? getCurrentUser() {
    final userId = _sessionBox.get(AppStrings.sessionKey);
    if (userId == null) return null;

    return _userBox.get(userId);
  }

  // ============================================================
  //  LOGOUT
  // ============================================================

  /// Logout — hapus sesi dan flag "Ingat Saya".
  Future<void> logout() async {
    await _sessionBox.delete(AppStrings.sessionKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.rememberMeKey);
  }

  // ============================================================
  //  HELPER METHODS
  // ============================================================

  /// Simpan sesi login (user ID) ke Hive box.
  Future<void> _saveSession(String userId) async {
    await _sessionBox.put(AppStrings.sessionKey, userId);
  }

  /// Cari user berdasarkan nomor HP.
  User? _findUserByPhone(String phone) {
    try {
      return _userBox.values.firstWhere(
        (user) => user.phone == phone,
      );
    } catch (_) {
      return null;
    }
  }
}
