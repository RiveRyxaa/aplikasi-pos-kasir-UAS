/// Model Kategori Produk.
/// Tabel: categories (SQLite)
class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  /// Konversi dari Map (SQLite row) ke Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'] as int?, name: map['name'] as String);
  }

  /// Konversi ke Map untuk insert/update SQLite
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  /// Copy with — buat salinan dengan perubahan tertentu
  Category copyWith({int? id, String? name}) {
    return Category(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
