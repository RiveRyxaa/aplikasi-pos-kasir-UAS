import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product.dart';
import '../../models/category.dart' as cat;
import '../../services/product_service.dart';
import '../../utils/constants.dart';

/// Product Form Screen — Tambah / Edit produk.
class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = tambah baru

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _barcodeController = TextEditingController();

  List<cat.Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    _loadCategories();

    if (_isEdit) {
      final p = widget.product!;
      _nameController.text = p.name;
      _priceController.text = p.price.toInt().toString();
      _costPriceController.text = p.costPrice?.toInt().toString() ?? '';
      _stockController.text = p.stock.toString();
      _minStockController.text = p.minStock.toString();
      _barcodeController.text = p.barcode ?? '';
      _selectedCategoryId = p.categoryId;
    } else {
      _stockController.text = '0';
      _minStockController.text = '5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (kIsWeb) return;
    final categories = await _productService.getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      // Default ke kategori pertama jika tambah baru
      if (!_isEdit && _categories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = _categories.first.id;
      }
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId,
        price: double.parse(_priceController.text.trim()),
        costPrice: _costPriceController.text.trim().isNotEmpty
            ? double.parse(_costPriceController.text.trim())
            : null,
        stock: int.parse(_stockController.text.trim()),
        minStock: int.parse(_minStockController.text.trim()),
        barcode: _barcodeController.text.trim().isNotEmpty
            ? _barcodeController.text.trim()
            : null,
        createdAt: widget.product?.createdAt,
      );

      if (_isEdit) {
        await _productService.updateProduct(product);
      } else {
        await _productService.addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      );

      Navigator.pop(context, true); // true = data berubah
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Nama Produk ===
              _buildSectionTitle('Informasi Produk'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Contoh: Nasi Goreng Spesial',
                icon: Icons.fastfood_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // === Kategori ===
              _buildCategoryDropdown(),

              const SizedBox(height: 16),

              // === Barcode ===
              _buildTextField(
                controller: _barcodeController,
                label: 'Kode Barcode (opsional)',
                hint: 'Scan atau input manual',
                icon: Icons.qr_code_rounded,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 28),

              // === Harga ===
              _buildSectionTitle('Harga'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Harga Jual',
                      hint: '15000',
                      icon: Icons.sell_rounded,
                      prefix: 'Rp ',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v.trim()) == null) return 'Angka saja';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _costPriceController,
                      label: 'Harga Beli',
                      hint: '10000',
                      icon: Icons.shopping_cart_outlined,
                      prefix: 'Rp ',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // === Stok ===
              _buildSectionTitle('Stok'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stok Saat Ini',
                      hint: '0',
                      icon: Icons.inventory_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v.trim()) == null) return 'Angka saja';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _minStockController,
                      label: 'Stok Minimum',
                      hint: '5',
                      icon: Icons.warning_amber_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        if (int.tryParse(v.trim()) == null) return 'Angka saja';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // === Tombol Simpan ===
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDark,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading
                        ? 'Menyimpan...'
                        : _isEdit
                            ? 'Simpan Perubahan'
                            : 'Tambah Produk',
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  REUSABLE WIDGETS
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        prefixText: prefix,
        prefixStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      // ignore: deprecated_member_use
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon:
            const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      dropdownColor: AppColors.card,
      items: _categories.map((c) {
        return DropdownMenuItem<int>(
          value: c.id,
          child: Text(c.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      validator: (v) => v == null ? 'Pilih kategori' : null,
    );
  }
}
