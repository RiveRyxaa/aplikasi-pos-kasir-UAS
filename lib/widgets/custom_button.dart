import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

/// Tombol reusable dengan gradient, loading state, dan animasi.
/// Digunakan di seluruh aplikasi untuk konsistensi UI.
class CustomButton extends StatefulWidget {
  /// Teks yang ditampilkan di tombol
  final String text;

  /// Callback saat tombol ditekan
  final VoidCallback? onPressed;

  /// Tampilkan loading indicator
  final bool isLoading;

  /// Icon di sebelah kiri teks (opsional)
  final IconData? icon;

  /// Gunakan style outline (transparan) bukan filled
  final bool isOutlined;

  /// Warna background (default: accent gold)
  final Color? backgroundColor;

  /// Warna teks & icon (default: primaryDark)
  final Color? foregroundColor;

  /// Lebar penuh (default: true)
  final bool fullWidth;

  /// Tinggi tombol (default: AppSizes.buttonHeight)
  final double? height;

  /// Border radius (default: AppSizes.radiusMD)
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.fullWidth = true,
    this.height,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.accent;
    final fgColor = widget.foregroundColor ?? AppColors.primaryDark;
    final radius = widget.borderRadius ?? AppSizes.radiusMD;
    final btnHeight = widget.height ?? AppSizes.buttonHeight;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: btnHeight,
          child: widget.isOutlined
              ? _buildOutlinedButton(bgColor, fgColor, radius)
              : _buildFilledButton(bgColor, fgColor, radius),
        ),
      ),
    );
  }

  /// Tombol filled (default) dengan gradient
  Widget _buildFilledButton(Color bgColor, Color fgColor, double radius) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor,
            bgColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: widget.onPressed != null && !widget.isLoading
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Center(child: _buildContent(fgColor)),
        ),
      ),
    );
  }

  /// Tombol outline (transparan)
  Widget _buildOutlinedButton(Color bgColor, Color fgColor, double radius) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: bgColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Center(child: _buildContent(bgColor)),
        ),
      ),
    );
  }

  /// Konten tombol: loading / icon + text
  Widget _buildContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
