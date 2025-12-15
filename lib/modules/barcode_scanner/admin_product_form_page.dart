import 'package:flutter/material.dart';
import '../../colors.dart';
import 'local_product_service.dart';
import 'nutrition_model.dart';

class AdminProductFormPage extends StatefulWidget {
  final String? initialBarcode;
  final String? initialName;

  const AdminProductFormPage({
    super.key,
    this.initialBarcode,
    this.initialName,
  });

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _imageController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _sugarController = TextEditingController();
  final _proteinController = TextEditingController();
  final _sodiumController = TextEditingController();

  bool _saving = false;
  final _service = LocalProductService();

  @override
  void initState() {
    super.initState();
    _barcodeController.text = widget.initialBarcode ?? '';
    _titleController.text = widget.initialName ?? '';
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _titleController.dispose();
    _brandController.dispose();
    _imageController.dispose();
    _caloriesController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _sugarController.dispose();
    _proteinController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Create local product',
            style: TextStyle(
              color: TColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Only title and barcode are required. Other fields help users see richer details.',
            style: TextStyle(
              color: TColors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: TColors.greyLight.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _barcodeController,
                label: 'Barcode number',
                hint: 'e.g. 5449000133327',
                keyboard: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Barcode is required';
                  }
                  if (!RegExp(r'^\d{6,}$').hasMatch(v.trim())) {
                    return 'Enter a valid numeric barcode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: 'Product title *',
                hint: 'Full product name',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (v.trim().length < 3) {
                    return 'Enter a longer title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _brandController,
                label: 'Brand (optional)',
                hint: 'e.g. Lays',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _imageController,
                label: 'Image URL (optional)',
                hint: 'https://...',
                keyboard: TextInputType.url,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Nutrition per 100g (optional)'),
              const SizedBox(height: 12),
              _buildNumberRow([
                _NumberField(controller: _caloriesController, label: 'Calories'),
                _NumberField(controller: _fatController, label: 'Fat (g)'),
              ]),
              const SizedBox(height: 12),
              _buildNumberRow([
                _NumberField(controller: _carbsController, label: 'Carbs (g)'),
                _NumberField(controller: _sugarController, label: 'Sugar (g)'),
              ]),
              const SizedBox(height: 12),
              _buildNumberRow([
                _NumberField(controller: _proteinController, label: 'Protein (g)'),
                _NumberField(controller: _sodiumController, label: 'Sodium (g)'),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _saving ? 'Saving...' : 'Save product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: TColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<_NumberField> items) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 12),
              child: _buildTextField(
                controller: items[i].controller,
                label: items[i].label,
                hint: '0',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: TColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.background3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: TColors.background3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final model = NutritionModel(
        productName: _titleController.text.trim(),
        brand: _brandController.text.trim().isNotEmpty
            ? _brandController.text.trim()
            : null,
        imageUrl:
            _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
        calories: _parseDouble(_caloriesController.text),
        fat: _parseDouble(_fatController.text),
        carbs: _parseDouble(_carbsController.text),
        sugar: _parseDouble(_sugarController.text),
        protein: _parseDouble(_proteinController.text),
        sodium: _parseDouble(_sodiumController.text),
        barcode: _barcodeController.text.trim(),
        nutrientLevels: const {},
        isFromGemini: false,
      );

      await _service.saveProduct(model);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: TColors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Product added to admin database',
                    style: TextStyle(color: TColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: TColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(model);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: TColors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not save product: $e',
                    style: const TextStyle(color: TColors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: TColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }
}

class _NumberField {
  final TextEditingController controller;
  final String label;

  _NumberField({required this.controller, required this.label});
}

