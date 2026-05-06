import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

/// Top Products — Placeholder, diimplementasi di Step 4.
class TopProducts extends StatelessWidget {
  const TopProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Produk Terlaris — Segera',
        style: GoogleFonts.poppins(color: AppColors.textHint),
      ),
    );
  }
}
