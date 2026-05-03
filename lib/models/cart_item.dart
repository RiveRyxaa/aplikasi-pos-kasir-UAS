import 'product.dart';

/// Model item keranjang belanja (in-memory, tidak disimpan ke database).
/// Digunakan saat proses transaksi di halaman kasir.
class CartItem {
  final Product product;
  int qty;

  CartItem({
    required this.product,
    this.qty = 1,
  });

  /// Subtotal = harga × qty
  double get subtotal => product.price * qty;

  /// Tambah qty
  void increment() => qty++;

  /// Kurangi qty (minimal 1)
  void decrement() {
    if (qty > 1) qty--;
  }

  /// Cek apakah stok cukup untuk qty saat ini
  bool get isStockAvailable => qty <= product.stock;

  @override
  String toString() =>
      'CartItem(product: ${product.name}, qty: $qty, subtotal: $subtotal)';
}

/// Manager keranjang belanja (singleton).
/// Menyimpan state keranjang selama sesi kasir aktif.
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  /// Ambil semua item di keranjang
  List<CartItem> get items => List.unmodifiable(_items);

  /// Jumlah jenis item di keranjang
  int get itemCount => _items.length;

  /// Total qty semua item
  int get totalQty => _items.fold(0, (sum, item) => sum + item.qty);

  /// Subtotal sebelum diskon
  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Tambah produk ke keranjang (jika sudah ada, tambah qty)
  void addProduct(Product product) {
    final existing = _items.indexWhere((i) => i.product.id == product.id);

    if (existing != -1) {
      _items[existing].increment();
    } else {
      _items.add(CartItem(product: product));
    }
  }

  /// Update qty item tertentu
  void updateQty(int productId, int newQty) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].qty = newQty;
      }
    }
  }

  /// Hapus item dari keranjang
  void removeItem(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
  }

  /// Kosongkan keranjang (setelah transaksi selesai)
  void clear() => _items.clear();

  /// Cek apakah keranjang kosong
  bool get isEmpty => _items.isEmpty;

  /// Cek apakah keranjang ada isi
  bool get isNotEmpty => _items.isNotEmpty;
}
