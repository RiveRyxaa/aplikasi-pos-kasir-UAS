import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/settings_service.dart';
import '../../utils/constants.dart';

/// Edit Profile Screen — Placeholder, diimplementasi di Step 3.
class EditProfileScreen extends StatelessWidget {
  final String storeName;
  final String storeAddress;
  final String storePhone;

  const EditProfileScreen({
    super.key,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profil',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Edit Profile — Segera diimplementasi'),
      ),
    );
  }
}
