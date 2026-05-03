import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

/// Payment Screen — Placeholder, akan diimplementasi di Step 7.
class PaymentScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Payment Screen - Segera diimplementasi'),
      ),
    );
  }
}
