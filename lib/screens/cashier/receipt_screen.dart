import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transaction.dart' as model;
import '../../models/transaction_item.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';

/// Receipt Screen — Struk digital setelah pembayaran berhasil.
class ReceiptScreen extends StatefulWidget {
  final int transactionId;
  final String invoiceNumber;

  const ReceiptScreen({
    super.key,
    required this.transactionId,
    required this.invoiceNumber,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();

  model.Transaction? _transaction;
  List<TransactionItem> _items = [];
  User? _currentUser;
  bool _isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _loadReceipt();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadReceipt() async {
    try {
      final transaction = await _transactionService
          .getTransactionById(widget.transactionId);
      final items = await _transactionService
          .getTransactionItems(widget.transactionId);

      if (!mounted) return;
      setState(() {
        _transaction = transaction;
        _items = items;
        _isLoading = false;
      });
      _animController.forward();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _newTransaction() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'tunai':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'transfer':
        return 'Transfer Bank';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Success icon
                        _buildSuccessHeader(),
                        const SizedBox(height: 20),

                        // Struk card
                        _buildReceiptCard(),
                        const SizedBox(height: 24),

                        // Action buttons
                        _buildActions(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ============================================================
  //  SUCCESS HEADER
  // ============================================================

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Pembayaran Berhasil!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Transaksi telah tersimpan',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  RECEIPT CARD
  // ============================================================

  Widget _buildReceiptCard() {
    if (_transaction == null) return const SizedBox.shrink();

    final trx = _transaction!;
    final createdAt = DateFormatter.parse(trx.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header toko
          Text(
            _currentUser?.storeName ?? 'Toko',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pemilik: ${_currentUser?.ownerName ?? '-'}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Info transaksi
          _buildInfoRow('No. Invoice', trx.invoiceNumber),
          const SizedBox(height: 4),
          _buildInfoRow(
            'Tanggal',
            createdAt != null
                ? DateFormatter.formatDateTime(createdAt)
                : '-',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            'Metode Bayar',
            _getPaymentMethodLabel(trx.paymentMethod),
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Daftar item
          ..._items.map((item) => _buildItemRow(item)),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Subtotal
          _buildInfoRow(
            'Subtotal',
            CurrencyFormatter.format(trx.total),
          ),

          // Diskon
          if (trx.discount > 0) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              'Diskon',
              '- ${CurrencyFormatter.format(trx.discount)}',
              valueColor: AppColors.error,
            ),
          ],

          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                CurrencyFormatter.format(trx.total - trx.discount),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Bayar & Kembalian
          _buildInfoRow(
            'Dibayar',
            CurrencyFormatter.format(trx.amountPaid ?? 0),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            'Kembalian',
            CurrencyFormatter.format(trx.changeAmount ?? 0),
            valueColor: AppColors.success,
          ),

          const SizedBox(height: 16),
          _buildDashedDivider(),
          const SizedBox(height: 12),

          // Terima kasih
          Text(
            'Terima kasih atas kunjungan Anda!',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(TransactionItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  ${item.qty} x ${CurrencyFormatter.format(item.price)}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        40,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0
                ? AppColors.textHint.withValues(alpha: 0.3)
                : Colors.transparent,
            height: 1,
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  ACTION BUTTONS
  // ============================================================

  Widget _buildActions() {
    return Column(
      children: [
        // Transaksi Baru
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _newTransaction,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(
              'Transaksi Baru',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Kembali ke Beranda
        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: _newTransaction,
            icon: const Icon(Icons.home_rounded),
            label: Text(
              'Kembali ke Beranda',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
