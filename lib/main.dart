import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/user.dart';
import 'services/database_service.dart';
import 'services/product_service.dart';
import 'utils/constants.dart';
import 'utils/date_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (user & sesi)
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(AppStrings.userBox);
    await Hive.openBox(AppStrings.sessionBox);
    debugPrint('✅ Hive initialized');
  } catch (e) {
    debugPrint('❌ Hive init error: $e');
  }

  // Inisialisasi SQLite database (produk, transaksi)
  // sqflite hanya support mobile/desktop, skip di web
  if (!kIsWeb) {
    try {
      await DatabaseService().database;
      await ProductService().seedDummyProducts();
      debugPrint('✅ SQLite initialized');
    } catch (e) {
      debugPrint('❌ SQLite init error: $e');
    }
  } else {
    debugPrint('ℹ️ Web mode — SQLite skipped, using fallback data');
  }

  // Inisialisasi locale Indonesia (format tanggal & mata uang)
  try {
    await DateFormatter.init();
  } catch (e) {
    debugPrint('❌ DateFormatter init error: $e');
  }

  runApp(const KasirApp());
}
