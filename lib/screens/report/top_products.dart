import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/report_service.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';

/// Tab Produk Terlaris — Ranking produk berdasarkan qty terjual.
class TopProducts extends StatefulWidget {
  const TopProducts({super.key});

  @override
  State<TopProducts> createState() => _TopProductsState();
}

class _TopProductsState extends State<TopProducts> {
  final ReportService _reportService = ReportService();

  List<Map<String, dynamic>> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (!kIsWeb) {
        final products = await _reportService.getTopProducts(limit: 10);
        if (!mounted) return;
        setState(() {
          _topProducts = products;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_topProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        itemCount: _topProducts.length + 1, // +1 untuk header
        itemBuilder: (context, index) {
          if (index == 0) return _buildPodium();
          return _buildRankTile(index - 1);
        },
      ),
    );
  }

  // ============================================================
  //  PODIUM TOP 3
  // ============================================================

  Widget _buildPodium() {
    if (_topProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          Text(
            '🏆 Produk Terlaris',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // #2 - Perak
              if (_topProducts.length >= 2)
                _buildPodiumItem(
                  rank: 2,
                  name: _topProducts[1]['productName'] as String,
                  qty: _topProducts[1]['totalQty'] as int,
                  height: 70,
                  color: const Color(0xFFC0C0C0),
                  emoji: '🥈',
                ),

              if (_topProducts.length >= 2) const SizedBox(width: 8),

              // #1 - Emas
              _buildPodiumItem(
                rank: 1,
                name: _topProducts[0]['productName'] as String,
                qty: _topProducts[0]['totalQty'] as int,
                height: 95,
                color: AppColors.accent,
                emoji: '🥇',
              ),

              if (_topProducts.length >= 3) const SizedBox(width: 8),

              // #3 - Perunggu
              if (_topProducts.length >= 3)
                _buildPodiumItem(
                  rank: 3,
                  name: _topProducts[2]['productName'] as String,
                  qty: _topProducts[2]['totalQty'] as int,
                  height: 55,
                  color: const Color(0xFFCD7F32),
                  emoji: '🥉',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int qty,
    required double height,
    required Color color,
    required String emoji,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$qty terjual',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),

          // Podium bar
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                top: BorderSide(color: color, width: 3),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  RANK LIST (semua produk termasuk top 3)
  // ============================================================

  Widget _buildRankTile(int index) {
    final item = _topProducts[index];
    final rank = index + 1;
    final name = item['productName'] as String;
    final qty = item['totalQty'] as int;
    final revenue = (item['totalRevenue'] as num).toDouble();

    Color rankColor;
    IconData rankIcon;
    switch (rank) {
      case 1:
        rankColor = AppColors.accent;
        rankIcon = Icons.emoji_events_rounded;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        rankIcon = Icons.emoji_events_rounded;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        rankIcon = Icons.emoji_events_rounded;
        break;
      default:
        rankColor = AppColors.textHint;
        rankIcon = Icons.tag_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: rank <= 3
            ? Border.all(color: rankColor.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: rank <= 3 ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 22)
                : Center(
                    child: Text(
                      '#$rank',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Nama produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$qty item terjual',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Total revenue
          Text(
            CurrencyFormatter.format(revenue),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
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
          Icon(Icons.leaderboard_outlined,
              size: 56, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Belum ada data penjualan',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            'Lakukan transaksi untuk melihat ranking',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
