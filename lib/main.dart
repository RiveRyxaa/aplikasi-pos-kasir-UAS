import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'models/user.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());

  // Buka box untuk data user & sesi login
  await Hive.openBox<User>(AppStrings.userBox);
  await Hive.openBox(AppStrings.sessionBox);

  runApp(const KasirApp());
}
