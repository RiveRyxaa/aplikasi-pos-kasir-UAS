import 'package:flutter/material.dart';

// ============================================================
//  WARNA UTAMA APLIKASI
// ============================================================

class AppColors {
  AppColors._();

  // --- Primary (Navy) ---
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2D5285);
  static const Color primaryDark = Color(0xFF0F1F33);

  // --- Accent (Kuning Emas) ---
  static const Color accent = Color(0xFFF4A92B);
  static const Color accentLight = Color(0xFFFFCA6A);
  static const Color accentDark = Color(0xFFD48E0F);

  // --- Background ---
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1A2E);

  // --- Status ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- Border & Divider ---
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // --- Gradient ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D5285),
      Color(0xFF1E3A5F),
      Color(0xFF0F1F33),
    ],
  );
}

// ============================================================
//  UKURAN & SPACING
// ============================================================

class AppSizes {
  AppSizes._();

  // --- Padding ---
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // --- Border Radius ---
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // --- Icon Sizes ---
  static const double iconSM = 18.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;

  // --- Input Field ---
  static const double inputHeight = 56.0;
  static const double buttonHeight = 52.0;
}

// ============================================================
//  STRING CONSTANTS
// ============================================================

class AppStrings {
  AppStrings._();

  static const String appName = 'Kasir';
  static const String appTagline = 'Solusi Kasir Digital Anda';

  // --- Auth ---
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String rememberMe = 'Ingat Saya';
  static const String forgotPassword = 'Lupa Password?';
  static const String noAccount = 'Belum punya akun?';
  static const String hasAccount = 'Sudah punya akun?';

  // --- Form Labels ---
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String storeName = 'Nama Toko';
  static const String ownerName = 'Nama Pemilik';
  static const String phone = 'Nomor HP';

  // --- Validation ---
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String passwordTooShort = 'Password minimal 4 karakter';
  static const String passwordMismatch = 'Password tidak cocok';
  static const String invalidPhone = 'Nomor HP tidak valid';

  // --- Hive Box Names ---
  static const String userBox = 'users';
  static const String sessionBox = 'session';
  static const String sessionKey = 'current_user_id';
  static const String rememberMeKey = 'remember_me';
}

// ============================================================
//  ROUTE NAMES
// ============================================================

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
}
