
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transaction.dart' as model;
import '../../services/report_service.dart';

import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../cashier/receipt_screen.dart';

/// Tab Riwayat Transaksi — List transaksi + filter tanggal & metode.
class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final ReportService _reportService = ReportService();

  List<model.Transaction> _transactions = [];
  bool _isLoading = true;

  // Filter state
  String _selectedMethod = 'semua'; // semua, tunai, qris, transfer
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      if (!kIsWeb) {
        List<model.Transaction> result;
        if (_selectedMethod == 'semua') {
          result = await _reportService.getTransactionsByDateRange(
              _fromDate, _toDate);
        } else {
          final byDate = await _reportService.getTransactionsByDateRange(
              _fromDate, _toDate);
          result = byDate
              .where((t) => t.paymentMethod == _selectedMethod)
              .toList();
        }
        if (!mounted) return;
        setState(() {
          _transactions = result;
        });
      }
    } catch (_) {
      // Error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      await _loadTransactions();
    }
  }

  void _onMethodChanged(String method) {
    setState(() => _selectedMethod = method);
    _loadTransactions();
  }

  void _openReceipt(model.Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          transactionId: transaction.id!,
          invoiceNumber: transaction.invoiceNumber,
        ),
      ),
    );
  }

  String _getMethodLabel(String method) {
    switch (method) {
      case 'tunai': return 'Tunai';
      case 'qris': return 'QRIS';
      case 'transfer': return 'Transfer';
      default: return method;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'tunai': return Icons.money_rounded;
      case 'qris': return Icons.qr_code_rounded;
      case 'transfer': return Icons.account_balance_rounded;
      default: return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent))
              : _transactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionList(),
        ),
      ],
    );
  }

  // ============================================================
  //  FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Date range picker
          GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.textHint.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${DateFormatter.formatShort(_fromDate)} — ${DateFormatter.formatShort(_toDate)}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textHint),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Method filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('semua', 'Semua'),
                _buildFilterChip('tunai', 'Tunai'),
                _buildFilterChip('qris', 'QRIS'),
                _buildFilterChip('transfer', 'Transfer'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Jumlah hasil
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '${_transactions.length} transaksi ditemukan',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String method, String label) {
    final isSelected = _selectedMethod == method;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _onMethodChanged(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textHint.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  TRANSACTION LIST
  // ============================================================

  Widget _buildTransactionList() {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final trx = _transactions[index];
          return _buildTransactionTile(trx);
        },
      ),
    );
  }

  Widget _buildTransactionTile(model.Transaction trx) {
    final createdAt = DateFormatter.parse(trx.createdAt);
    final netTotal = trx.total - trx.discount;

    return GestureDetector(
      onTap: () => _openReceipt(trx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon metode bayar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMethodIcon(trx.paymentMethod),
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Info transaksi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trx.invoiceNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        createdAt != null
                            ? DateFormatter.formatDateTime(createdAt)
                            : '-',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getMethodLabel(trx.paymentMethod),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(netTotal),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (trx.discount > 0)
                  Text(
                    '-${CurrencyFormatter.format(trx.discount)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Belum ada transaksi',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            'Transaksi akan muncul setelah pembayaran',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
