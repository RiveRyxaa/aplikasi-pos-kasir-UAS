import 'package:hive/hive.dart';

part 'user.g.dart';

/// Model User untuk autentikasi lokal.
/// Data disimpan di Hive box 'users'.
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String storeName;

  @HiveField(2)
  final String ownerName;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final DateTime createdAt;

  User({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    required this.password,
    required this.createdAt,
  });

  /// Factory constructor untuk membuat User baru dengan auto-generated ID
  factory User.create({
    required String storeName,
    required String ownerName,
    required String phone,
    required String password,
  }) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storeName: storeName,
      ownerName: ownerName,
      phone: phone,
      password: password,
      createdAt: DateTime.now(),
    );
  }
}
