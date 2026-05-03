import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/currency_formatter.dart';

/// Card produk untuk grid di halaman kasir.
/// Menampilkan nama, harga, stok, dan badge stok menipis.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stock <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? AppColors.card.withValues(alpha: 0.6)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: isOutOfStock
                ? AppColors.textHint.withValues(alpha: 0.2)
                : AppColors.primary.withValues(alpha: 0.08),
          ),
          boxShadow: isOutOfStock
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Konten utama
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon produk
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: _getCategoryColor(),
                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nama produk
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Harga
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? AppColors.textHint
                          : AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Stok
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: isLowStock
                            ? AppColors.error
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOutOfStock ? 'Habis' : 'Stok: ${product.stock}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isLowStock
                              ? AppColors.error
                              : AppColors.textHint,
                          fontWeight: isLowStock
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge stok menipis / habis
            if (isOutOfStock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HABIS',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else if (isLowStock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'MENIPIS',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

            // Tombol + di pojok kanan bawah
            if (!isOutOfStock)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Warna berdasarkan kategori
  Color _getCategoryColor() {
    switch (product.categoryId) {
      case 1: return AppColors.primary;    // Makanan
      case 2: return AppColors.info;       // Minuman
      case 3: return AppColors.accent;     // Snack
      case 4: return AppColors.error;      // Rokok
      default: return AppColors.textSecondary; // Lainnya
    }
  }

  /// Icon berdasarkan kategori
  IconData _getCategoryIcon() {
    switch (product.categoryId) {
      case 1: return Icons.restaurant_rounded;     // Makanan
      case 2: return Icons.local_cafe_rounded;      // Minuman
      case 3: return Icons.fastfood_rounded;        // Snack
      case 4: return Icons.smoking_rooms_rounded;   // Rokok
      default: return Icons.shopping_bag_rounded;   // Lainnya
    }
  }
}
