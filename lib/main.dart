import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/user.dart';
import 'services/database_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive (user & sesi)
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>(AppStrings.userBox);
  await Hive.openBox(AppStrings.sessionBox);

  // Inisialisasi SQLite database (produk, transaksi)
  await DatabaseService().database;

  runApp(const KasirApp());
}
