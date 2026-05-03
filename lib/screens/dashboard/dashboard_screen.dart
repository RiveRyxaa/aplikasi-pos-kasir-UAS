import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/summary_card.dart';

/// Dashboard Screen — Ringkasan hari ini + shortcut menu.
class DashboardScreen extends StatefulWidget {
  /// Callback untuk navigasi ke tab lain via BottomNav
  final void Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  int _totalTransactions = 0;
  double _totalRevenue = 0;
  int _totalItems = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    _loadDailySummary();
  }

  Future<void> _loadDailySummary() async {
    setState(() => _isLoading = true);

    try {
      final summary = await _dbService.getDailySummary();
      if (!mounted) return;

      setState(() {
        _totalTransactions = summary['totalTransactions'] as int;
        _totalRevenue = summary['totalRevenue'] as double;
        _totalItems = summary['totalItems'] as int;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _loadDailySummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDateBadge(),
              const SizedBox(height: 20),
              _buildSummarySection(),
              const SizedBox(height: 28),
              _buildShortcutSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Greeting & Store
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentUser?.ownerName ?? 'Pemilik',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Store badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: Text(
                    _currentUser?.storeName ?? 'Toko',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  DATE BADGE
  // ============================================================

  Widget _buildDateBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormatter.formatFull(DateTime.now()),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  SUMMARY CARDS
  // ============================================================

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Hari Ini',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else
            Column(
              children: [
                // Row 1: Transaksi & Pendapatan
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Transaksi',
                        value: '$_totalTransactions',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        subtitle: 'Hari ini',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Pendapatan',
                        value: CurrencyFormatter.format(_totalRevenue),
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                        subtitle: 'Hari ini',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Item Terjual
                SummaryCard(
                  title: 'Item Terjual',
                  value: '$_totalItems item',
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.accent,
                  subtitle: 'Hari ini',
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  //  SHORTCUT MENU
  // ============================================================

  Widget _buildShortcutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Cepat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildShortcutItem(
                  icon: Icons.add_shopping_cart_rounded,
                  label: 'Transaksi\nBaru',
                  color: AppColors.primary,
                  onTap: () => widget.onNavigateToTab?.call(1), // Tab Kasir
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShortcutItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Laporan\nPenjualan',
                  color: AppColors.info,
                  onTap: () => widget.onNavigateToTab?.call(3), // Tab Laporan
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShortcutItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Kelola\nProduk',
                  color: AppColors.accent,
                  onTap: () => widget.onNavigateToTab?.call(2), // Tab Produk
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  HELPERS
  // ============================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 👋';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }
}
