/// Model Item Transaksi (detail produk dalam 1 transaksi).
/// Tabel: transaction_items (SQLite)
class TransactionItem {
  final int? id;
  final int? transactionId;
  final int? productId;
  final String productName;
  final double price;
  final int qty;
  final double subtotal;

  TransactionItem({
    this.id,
    this.transactionId,
    this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.subtotal,
  });

  /// Konversi dari Map (SQLite row) ke TransactionItem
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int?,
      productId: map['product_id'] as int?,
      productName: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      qty: map['qty'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  /// Konversi ke Map untuk insert/update SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'qty': qty,
      'subtotal': subtotal,
    };
  }

  /// Copy with
  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    double? price,
    int? qty,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  String toString() =>
      'TransactionItem(id: $id, product: $productName, qty: $qty, subtotal: $subtotal)';
}
