import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/category.dart' as cat;
import '../../services/product_service.dart';
import '../../utils/constants.dart';

/// Bottom sheet untuk kelola kategori (tambah, edit, hapus).
class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key});

  /// Tampilkan bottom sheet dan return true jika ada perubahan.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CategoryDialog(),
    );
  }

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final ProductService _productService = ProductService();
  final TextEditingController _inputController = TextEditingController();

  List<cat.Category> _categories = [];
  bool _isLoading = true;
  bool _hasChanged = false;
  int? _editingId; // null = mode tambah, int = mode edit

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _productService.getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _addCategory() async {
    final name = _inputController.text.trim();
    if (name.isEmpty) return;

    await _productService.addCategory(name);
    _inputController.clear();
    _hasChanged = true;
    await _loadCategories();
  }

  Future<void> _updateCategory() async {
    final name = _inputController.text.trim();
    if (name.isEmpty || _editingId == null) return;

    await _productService.updateCategory(_editingId!, name);
    _inputController.clear();
    _editingId = null;
    _hasChanged = true;
    await _loadCategories();
  }

  void _startEditing(cat.Category category) {
    setState(() {
      _editingId = category.id;
      _inputController.text = category.name;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingId = null;
      _inputController.clear();
    });
  }

  Future<void> _deleteCategory(cat.Category category) async {
    // Cek apakah ada produk di kategori ini
    final count =
        await _productService.getProductCountByCategory(category.id!);

    if (!mounted) return;

    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak bisa hapus "${category.name}" — masih ada $count produk',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Text('Hapus Kategori',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Yakin ingin menghapus "${category.name}"?',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _productService.deleteCategory(category.id!);
      _hasChanged = true;
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kelola Kategori',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, _hasChanged),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textHint),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _editingId != null
                          ? 'Edit nama kategori...'
                          : 'Tambah kategori baru...',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textHint),
                      prefixIcon: Icon(
                        _editingId != null
                            ? Icons.edit_rounded
                            : Icons.add_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textHint.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tombol simpan / tambah
                GestureDetector(
                  onTap: _editingId != null ? _updateCategory : _addCategory,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _editingId != null
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),

                // Tombol batal edit
                if (_editingId != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _cancelEditing,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.error, size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category list
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: AppColors.accent),
                    ),
                  )
                : _categories.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Belum ada kategori',
                          style: GoogleFonts.poppins(
                              color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _buildCategoryTile(category);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(cat.Category category) {
    final isEditing = _editingId == category.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEditing
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: isEditing
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                category.name.isNotEmpty
                    ? category.name[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              category.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () => _startEditing(category),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.info, size: 16),
            ),
          ),
          const SizedBox(width: 6),

          // Delete button
          GestureDetector(
            onTap: () => _deleteCategory(category),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
