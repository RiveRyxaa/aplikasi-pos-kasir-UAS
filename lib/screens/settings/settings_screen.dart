import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

/// Placeholder Settings Screen — Module 6
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pengaturan',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pengaturan lengkap akan hadir di Module 6',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // Tombol Logout
              CustomButton(
                text: AppStrings.logout,
                icon: Icons.logout_rounded,
                isOutlined: true,
                backgroundColor: AppColors.error,
                onPressed: () => _handleLogout(context),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
