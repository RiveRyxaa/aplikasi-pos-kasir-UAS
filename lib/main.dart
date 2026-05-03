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
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>(AppStrings.userBox);
  await Hive.openBox(AppStrings.sessionBox);

  // Inisialisasi SQLite database (produk, transaksi)
  // sqflite tidak support web, jadi skip di platform web
  if (!kIsWeb) {
    await DatabaseService().database;
    // Seed produk dummy untuk testing (hanya sekali)
    await ProductService().seedDummyProducts();
  }

  // Inisialisasi locale Indonesia (format tanggal & mata uang)
  await DateFormatter.init();

  runApp(const KasirApp());
}
