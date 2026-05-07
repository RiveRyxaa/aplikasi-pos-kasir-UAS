
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/report_service.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/summary_card.dart';
import 'transaction_history.dart';
import 'top_products.dart';

/// Report Screen — Laporan penjualan dengan 3 tab.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();

  Map<String, dynamic> _todaySales = {};
  Map<String, dynamic> _monthlySales = {};
  List<Map<String, dynamic>> _weeklySales = [];
  List<Map<String, dynamic>> _paymentBreakdown = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSummary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    try {
      if (!kIsWeb) {
        final today = await _reportService.getDailySales(DateTime.now());
        final monthly = await _reportService.getMonthlySales();
        final weekly = await _reportService.getWeeklySales();
        final breakdown = await _reportService.getTodayPaymentBreakdown();

        if (!mounted) return;
        setState(() {
          _todaySales = today;
          _monthlySales = monthly;
          _weeklySales = weekly;
          _paymentBreakdown = breakdown;
        });
      }
    } catch (_) {
      // Error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                const TransactionHistory(),
                const TopProducts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  HEADER + TABS
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ringkasan penjualan & riwayat',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Ringkasan'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Terlaris'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  //  TAB 1: RINGKASAN
  // ============================================================

  Widget _buildSummaryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Hari Ini ===
            Text(
              'Hari Ini',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Transaksi',
                    value: '${_todaySales['totalTransactions'] ?? 0}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    subtitle: 'Hari ini',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Pendapatan',
                    value: CurrencyFormatter.format(
                        (_todaySales['totalRevenue'] as num?)?.toDouble() ?? 0),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.success,
                    subtitle: 'Hari ini',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // === 30 Hari Terakhir ===
            Text(
              '30 Hari Terakhir',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Transaksi',
                    value: '${_monthlySales['totalTransactions'] ?? 0}',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.info,
                    subtitle: 'Bulan ini',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Pendapatan',
                    value: CurrencyFormatter.format(
                        (_monthlySales['totalRevenue'] as num?)?.toDouble() ??
                            0),
                    icon: Icons.savings_rounded,
                    color: AppColors.accent,
                    subtitle: 'Bulan ini',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // === Grafik 7 Hari ===
            Text(
              'Pendapatan 7 Hari Terakhir',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildWeeklyChart(),

            const SizedBox(height: 24),

            // === Breakdown Metode Bayar ===
            if (_paymentBreakdown.isNotEmpty) ...[
              Text(
                'Metode Pembayaran Hari Ini',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._paymentBreakdown.map((item) => _buildPaymentRow(item)),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  WEEKLY CHART (bar chart sederhana)
  // ============================================================

  Widget _buildWeeklyChart() {
    if (_weeklySales.isEmpty) {
      return const SizedBox.shrink();
    }

    // Cari max revenue untuk skala
    double maxRevenue = 1;
    for (final day in _weeklySales) {
      final rev = (day['totalRevenue'] as num?)?.toDouble() ?? 0;
      if (rev > maxRevenue) maxRevenue = rev;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklySales.map((day) {
                final revenue =
                    (day['totalRevenue'] as num?)?.toDouble() ?? 0;
                final ratio = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
                final isToday = day['label'] ==
                    _weeklySales.last['label'];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Nilai di atas bar
                        if (revenue > 0)
                          Text(
                            _formatShortCurrency(revenue),
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                        const SizedBox(height: 4),

                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: (ratio * 100).clamp(4, 100),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Label hari
          Row(
            children: _weeklySales.map((day) {
              final isToday =
                  day['label'] == _weeklySales.last['label'];
              return Expanded(
                child: Text(
                  day['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  PAYMENT BREAKDOWN ROW
  // ============================================================

  Widget _buildPaymentRow(Map<String, dynamic> item) {
    final method = item['method'] as String;
    final count = item['count'] as int;
    final total = (item['total'] as num).toDouble();

    IconData icon;
    String label;
    switch (method) {
      case 'tunai':
        icon = Icons.money_rounded;
        label = 'Tunai';
        break;
      case 'qris':
        icon = Icons.qr_code_rounded;
        label = 'QRIS';
        break;
      case 'transfer':
        icon = Icons.account_balance_rounded;
        label = 'Transfer';
        break;
      default:
        icon = Icons.payment_rounded;
        label = method;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$count transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(total),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  HELPERS
  // ============================================================

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toInt().toString();
  }
}
