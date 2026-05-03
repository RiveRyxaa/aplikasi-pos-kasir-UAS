import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

/// Receipt Screen — Placeholder, akan diimplementasi di Step 8.
class ReceiptScreen extends StatelessWidget {
  final int transactionId;
  final String invoiceNumber;

  const ReceiptScreen({
    super.key,
    required this.transactionId,
    required this.invoiceNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Struk',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Receipt Screen - Invoice: $invoiceNumber'),
      ),
    );
  }
}
