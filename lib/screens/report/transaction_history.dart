import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

/// Transaction History — Placeholder, diimplementasi di Step 3.
class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Riwayat Transaksi — Segera',
        style: GoogleFonts.poppins(color: AppColors.textHint),
      ),
    );
  }
}
