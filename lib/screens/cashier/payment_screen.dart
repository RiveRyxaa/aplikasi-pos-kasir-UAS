import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/cart_item.dart';
import '../../models/transaction_item.dart';
import '../../services/transaction_service.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import 'receipt_screen.dart';

/// Payment Screen — Pilih metode bayar, input nominal, kembalian.
class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final double discount;
  final double total;

  const PaymentScreen({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TransactionService _transactionService = TransactionService();
  final CartManager _cart = CartManager();
  final TextEditingController _amountController = TextEditingController();

  String _selectedMethod = 'tunai';
  double _amountPaid = 0;
  bool _isProcessing = false;

  double get _change => (_amountPaid - widget.total).clamp(0, double.infinity);
  bool get _canPay {
    if (_selectedMethod == 'tunai') {
      return _amountPaid >= widget.total;
    }
    return true; // QRIS & Transfer tidak perlu input nominal
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() {
      _amountPaid = double.tryParse(value) ?? 0;
    });
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _amountPaid = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  Future<void> _processPayment() async {
    if (!_canPay || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Konversi cart items ke TransactionItem
      final items = _cart.items.map((cartItem) {
        return TransactionItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          qty: cartItem.qty,
          subtotal: cartItem.subtotal,
        );
      }).toList();

      // Untuk non-tunai, amountPaid = total
      final amountPaid = _selectedMethod == 'tunai' ? _amountPaid : widget.total;
      final changeAmount = _selectedMethod == 'tunai' ? _change : 0.0;

      // Simpan transaksi
      final transactionId = await _transactionService.createTransaction(
        total: widget.subtotal,
        discount: widget.discount,
        paymentMethod: _selectedMethod,
        amountPaid: amountPaid,
        changeAmount: changeAmount,
        items: items,
      );

      // Ambil data transaksi untuk struk
      final transaction = await _transactionService.getTransactionById(transactionId);

      // Kosongkan keranjang
      _cart.clear();

      if (!mounted) return;

      // Navigasi ke struk, replace semua halaman kasir
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            transactionId: transactionId,
            invoiceNumber: transaction!.invoiceNumber,
          ),
        ),
        (route) => route.isFirst, // Kembali ke MainShell
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memproses pembayaran: $e',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total yang harus dibayar
            _buildTotalCard(),
            const SizedBox(height: 24),

            // Pilih metode bayar
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Input nominal (khusus Tunai)
            if (_selectedMethod == 'tunai') ...[
              _buildAmountInput(),
              const SizedBox(height: 16),
              _buildQuickAmounts(),
              const SizedBox(height: 24),
              _buildChangeCard(),
              const SizedBox(height: 24),
            ],

            // Tombol Bayar
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  TOTAL CARD
  // ============================================================

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          Text(
            'Total Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(widget.total),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          if (widget.discount > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Diskon: ${CurrencyFormatter.format(widget.discount)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  //  PAYMENT METHODS
  // ============================================================

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMethodChip('tunai', Icons.money_rounded, 'Tunai')),
            const SizedBox(width: 10),
            Expanded(child: _buildMethodChip('qris', Icons.qr_code_rounded, 'QRIS')),
            const SizedBox(width: 10),
            Expanded(child: _buildMethodChip('transfer', Icons.account_balance_rounded, 'Transfer')),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodChip(String method, IconData icon, String label) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  AMOUNT INPUT (Tunai)
  // ============================================================

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nominal Uang Diterima',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: _onAmountChanged,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            hintText: '0',
            hintStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: BorderSide(
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: BorderSide(
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  QUICK AMOUNT BUTTONS
  // ============================================================

  Widget _buildQuickAmounts() {
    final total = widget.total;

    // Generate quick amounts berdasarkan total
    final quickAmounts = <double>[];

    // Uang Pas
    quickAmounts.add(total);

    // Pembulatan ke atas
    if (total <= 50000) {
      quickAmounts.addAll([20000, 50000, 100000]);
    } else if (total <= 100000) {
      quickAmounts.addAll([50000, 100000, 200000]);
    } else {
      quickAmounts.addAll([100000, 200000, 500000]);
    }

    // Hapus duplikat dan sort
    final uniqueAmounts = quickAmounts.toSet().toList()..sort();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: uniqueAmounts.map((amount) {
        final isExact = amount == total;
        return GestureDetector(
          onTap: () => _setQuickAmount(amount),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _amountPaid == amount
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _amountPaid == amount
                    ? AppColors.primary
                    : AppColors.textHint.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              isExact ? 'Uang Pas' : CurrencyFormatter.format(amount),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: _amountPaid == amount
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: _amountPaid == amount
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  //  CHANGE CARD (Kembalian)
  // ============================================================

  Widget _buildChangeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _canPay
            ? AppColors.success.withValues(alpha: 0.08)
            : AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: _canPay
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _canPay ? 'Kembalian' : 'Kurang',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _canPay ? AppColors.success : AppColors.error,
            ),
          ),
          Text(
            _canPay
                ? CurrencyFormatter.format(_change)
                : CurrencyFormatter.format(widget.total - _amountPaid),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _canPay ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  PAY BUTTON
  // ============================================================

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: (_canPay && !_isProcessing) ? _processPayment : null,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryDark,
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          _isProcessing ? 'Memproses...' : 'Bayar & Cetak Struk',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
