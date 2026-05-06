import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product.dart';
import '../../utils/constants.dart';

/// Product Form Screen — Placeholder, diimplementasi di Step 2.
class ProductFormScreen extends StatelessWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product == null ? 'Tambah Produk' : 'Edit Produk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Form Produk - Segera diimplementasi'),
      ),
    );
  }
}
