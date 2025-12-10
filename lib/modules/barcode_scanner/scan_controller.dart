import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../colors.dart';
import 'nutrition_model.dart';
import 'nutrition_service.dart';

/// Scan state enum
enum ScanState {
  idle,      // Initial state, ready to scan
  scanning,  // Currently scanning barcode
  loading,   // Barcode scanned, fetching nutrition data
  result,    // Nutrition data loaded successfully
  error,     // Error occurred
}

/// Controller for barcode scanning and nutrition lookup
/// Uses GetX for state management
class ScanController extends GetxController {
  final NutritionService _nutritionService = NutritionService();

  // Observable state
  final _scanState = ScanState.idle.obs;
  final _nutritionData = Rxn<NutritionModel>();
  final _errorMessage = ''.obs;
  final _scannedBarcode = ''.obs;
  final _productName = ''.obs; // For manual entry when barcode not found
  
  // Barcode hold timer
  String? _currentBarcode;
  DateTime? _barcodeDetectedTime;
  Timer? _holdTimer;
  final _holdProgress = 0.0.obs; // 0.0 to 1.0 for 2 seconds
  final _isHolding = false.obs;

  // Getters
  ScanState get scanState => _scanState.value;
  NutritionModel? get nutritionData => _nutritionData.value;
  String get errorMessage => _errorMessage.value;
  String get scannedBarcode => _scannedBarcode.value;
  String get productName => _productName.value;
  double get holdProgress => _holdProgress.value;
  bool get isHolding => _isHolding.value;
  
  bool get isIdle => _scanState.value == ScanState.idle;
  bool get isScanning => _scanState.value == ScanState.scanning;
  bool get isLoading => _scanState.value == ScanState.loading;
  bool get hasResult => _scanState.value == ScanState.result;
  bool get hasError => _scanState.value == ScanState.error;

  @override
  void onClose() {
    _holdTimer?.cancel();
    super.onClose();
  }

  /// Start scanning - reset state and prepare for new scan
  void startScanning() {
    _scanState.value = ScanState.scanning;
    _errorMessage.value = '';
    _nutritionData.value = null;
    _scannedBarcode.value = '';
    _currentBarcode = null;
    _barcodeDetectedTime = null;
    _holdProgress.value = 0.0;
    _isHolding.value = false;
    _holdTimer?.cancel();
  }

  /// Validate barcode format
  bool _isValidBarcode(String barcode) {
    if (barcode.isEmpty || barcode.trim().isEmpty) return false;
    
    // Clean barcode - remove whitespace and common separators
    final cleaned = barcode.trim().replaceAll(RegExp(r'[\s\-]'), '');
    
    // Remove any non-digit characters for validation
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Valid barcode lengths: EAN-13 (13), EAN-8 (8), UPC-A (12), UPC-E (6-8), Code128 (variable)
    final validLengths = [6, 7, 8, 12, 13, 14];
    if (!validLengths.contains(digitsOnly.length)) return false;
    
    // Must contain only digits (after cleaning) and be at least 6 digits
    if (digitsOnly.length < 6) return false;
    
    // Additional validation: check if it looks like a valid barcode
    // Most product barcodes start with specific prefixes
    // But we'll be lenient and just check format
    
    return true;
  }

  /// Handle barcode detection with 2-second hold requirement
  void onBarcodeDetected(String barcode) {
    // Don't process if already loading or has result
    if (_scanState.value == ScanState.loading || _scanState.value == ScanState.result) {
      return;
    }

    // Validate barcode format
    if (!_isValidBarcode(barcode)) {
      _currentBarcode = null;
      _barcodeDetectedTime = null;
      _holdProgress.value = 0.0;
      _isHolding.value = false;
      _holdTimer?.cancel();
      return;
    }

    // If same barcode is detected, continue holding
    if (_currentBarcode == barcode && _barcodeDetectedTime != null) {
      // Already holding this barcode, timer will handle it
      return;
    }

    // New barcode detected - start hold timer
    _currentBarcode = barcode;
    _barcodeDetectedTime = DateTime.now();
    _isHolding.value = true;
    _holdProgress.value = 0.0;
    
    // Cancel previous timer if any
    _holdTimer?.cancel();
    
    // Start 2-second hold timer
    const holdDuration = Duration(seconds: 2);
    final startTime = DateTime.now();
    
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentBarcode != barcode || _barcodeDetectedTime == null) {
        // Barcode changed or reset, cancel timer
        timer.cancel();
        _holdProgress.value = 0.0;
        _isHolding.value = false;
        return;
      }
      
      final elapsed = DateTime.now().difference(startTime);
      final progress = elapsed.inMilliseconds / holdDuration.inMilliseconds;
      
      if (progress >= 1.0) {
        // Hold complete - process the barcode
        timer.cancel();
        _holdProgress.value = 1.0;
        _isHolding.value = false;
        _processBarcode(barcode);
      } else {
        _holdProgress.value = progress;
      }
    });
  }

  /// Process barcode after successful 2-second hold
  Future<void> _processBarcode(String barcode) async {
    try {
      // Validate barcode one more time
      if (!_isValidBarcode(barcode)) {
        _setError('Invalid barcode format');
        return;
      }

      // Prevent duplicate processing
      if (_scannedBarcode.value == barcode && _scanState.value == ScanState.loading) {
        return;
      }

      _scannedBarcode.value = barcode;
      _scanState.value = ScanState.loading;
      _errorMessage.value = '';
      _holdProgress.value = 0.0;

      // Fetch nutrition data using Gemini AI
      final nutrition = await _nutritionService.fetchNutrition(
        barcode, 
        productName: _productName.value.isNotEmpty ? _productName.value : null,
      );

      if (nutrition != null) {
        _nutritionData.value = nutrition;
        _scanState.value = ScanState.result;
      } else {
        _setError('Unable to get nutrition data');
        _showSnackbar(
          'Unable to get data', 
          'Could not fetch nutrition information. Try entering the product name manually.',
        );
      }
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      _setError(errorMsg);
      _showSnackbar('Error', errorMsg);
    } finally {
      // Reset hold state
      _currentBarcode = null;
      _barcodeDetectedTime = null;
      _holdProgress.value = 0.0;
      _isHolding.value = false;
    }
  }

  /// Reset to idle state
  void reset() {
    _holdTimer?.cancel();
    _scanState.value = ScanState.idle;
    _nutritionData.value = null;
    _errorMessage.value = '';
    _scannedBarcode.value = '';
    _productName.value = '';
    _currentBarcode = null;
    _barcodeDetectedTime = null;
    _holdProgress.value = 0.0;
    _isHolding.value = false;
  }

  /// Rescan - go back to scanning state
  void rescan() {
    reset();
    startScanning();
  }

  /// Try fetching nutrition with manual product name
  Future<void> fetchWithProductName(String productName) async {
    if (productName.isEmpty) return;
    
    try {
      _productName.value = productName;
      _scanState.value = ScanState.loading;
      _errorMessage.value = '';
      
      // Try Gemini directly with product name
      final nutrition = await _nutritionService.fetchNutrition(
        _scannedBarcode.value.isNotEmpty ? _scannedBarcode.value : 'unknown',
        productName: productName,
      );
      
      if (nutrition != null) {
        _nutritionData.value = nutrition;
        _scanState.value = ScanState.result;
      } else {
        _setError('Unable to get nutrition data');
        _showSnackbar('Error', 'Could not fetch nutrition data for this product.');
      }
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      _setError(errorMsg);
      _showSnackbar('Error', errorMsg);
    }
  }

  /// Set error state with message
  void _setError(String message) {
    _errorMessage.value = message;
    _scanState.value = ScanState.error;
  }

  /// Extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('internet') || 
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return 'Network error';
    } else if (errorString.contains('not found') || 
               errorString.contains('404')) {
      return 'Product not found';
    } else if (errorString.contains('invalid barcode')) {
      return 'Invalid barcode';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  /// Show snackbar notification
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.error.withOpacity(0.9),
      colorText: TColors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.error_outline,
        color: TColors.white,
      ),
    );
  }

}

