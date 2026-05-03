import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/cart_item.dart';
import '../../utils/constants.dart';
import '../../utils/currency_formatter.dart';
import 'payment_screen.dart';

/// Cart Screen — Keranjang belanja dengan qty, diskon, dan total.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartManager _cart = CartManager();
  final TextEditingController _discountController = TextEditingController();
  double _discount = 0;

  double get _subtotal => _cart.subtotal;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _updateDiscount(String value) {
    setState(() {
      _discount = double.tryParse(value) ?? 0;
    });
  }

  void _incrementQty(CartItem item) {
    if (item.qty < item.product.stock) {
      setState(() => item.increment());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok ${item.product.name} tidak mencukupi',
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

  void _decrementQty(CartItem item) {
    setState(() {
      if (item.qty > 1) {
        item.decrement();
      } else {
        _removeItem(item);
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cart.removeItem(item.product.id!);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.product.name} dihapus dari keranjang',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Jika keranjang kosong, kembali
    if (_cart.isEmpty) {
      Navigator.pop(context);
    }
  }

  void _goToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          subtotal: _subtotal,
          discount: _discount,
          total: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Keranjang (${_cart.totalQty} item)',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _cart.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Daftar item
                Expanded(child: _buildItemList()),

                // Footer: Diskon + Total + Tombol Bayar
                _buildFooter(),
              ],
            ),
    );
  }

  // ============================================================
  //  EMPTY CART
  // ============================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang kosong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih produk dari halaman Kasir',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  ITEM LIST
  // ============================================================

  Widget _buildItemList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _cart.items.length,
      itemBuilder: (context, index) {
        final item = _cart.items[index];
        return _buildCartItem(item);
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
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
            // Icon produk
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fastfood_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Nama & harga satuan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
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
                    CurrencyFormatter.format(item.product.price),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Kontrol qty
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol -
                  GestureDetector(
                    onTap: () => _decrementQty(item),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.qty <= 1
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(9),
                          bottomLeft: Radius.circular(9),
                        ),
                      ),
                      child: Icon(
                        item.qty <= 1
                            ? Icons.delete_outline_rounded
                            : Icons.remove_rounded,
                        size: 16,
                        color: item.qty <= 1
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                  ),

                  // Qty
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${item.qty}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Tombol +
                  GestureDetector(
                    onTap: () => _incrementQty(item),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(9),
                          bottomRight: Radius.circular(9),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Subtotal
            SizedBox(
              width: 80,
              child: Text(
                CurrencyFormatter.format(item.subtotal),
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  FOOTER: Diskon + Total + Tombol Bayar
  // ============================================================

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input Diskon
            Row(
              children: [
                Text(
                  'Diskon',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  height: 36,
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    onChanged: _updateDiscount,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      prefixText: 'Rp ',
                      prefixStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.textHint.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.textHint.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(_subtotal),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            if (_discount > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diskon',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                  Text(
                    '- ${CurrencyFormatter.format(_discount)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(_total),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tombol Lanjut Bayar
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _cart.isEmpty ? null : _goToPayment,
                icon: const Icon(Icons.payment_rounded),
                label: Text(
                  'Lanjut Bayar',
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
          ],
        ),
      ),
    );
  }
}
