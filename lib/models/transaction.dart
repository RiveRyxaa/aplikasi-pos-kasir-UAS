/// Model Transaksi.
/// Tabel: transactions (SQLite)
class Transaction {
  final int? id;
  final String invoiceNumber;
  final double total;
  final double discount;
  final String paymentMethod; // tunai / qris / transfer
  final double? amountPaid;
  final double? changeAmount;
  final String? createdAt;

  Transaction({
    this.id,
    required this.invoiceNumber,
    required this.total,
    this.discount = 0,
    required this.paymentMethod,
    this.amountPaid,
    this.changeAmount,
    this.createdAt,
  });

  /// Konversi dari Map (SQLite row) ke Transaction
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      total: (map['total'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String,
      amountPaid: map['amount_paid'] != null
          ? (map['amount_paid'] as num).toDouble()
          : null,
      changeAmount: map['change_amount'] != null
          ? (map['change_amount'] as num).toDouble()
          : null,
      createdAt: map['created_at'] as String?,
    );
  }

  /// Konversi ke Map untuk insert/update SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'total': total,
      'discount': discount,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  /// Total setelah diskon
  double get totalAfterDiscount => total - discount;

  /// Copy with
  Transaction copyWith({
    int? id,
    String? invoiceNumber,
    double? total,
    double? discount,
    String? paymentMethod,
    double? amountPaid,
    double? changeAmount,
    String? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, invoice: $invoiceNumber, total: $total)';
}
