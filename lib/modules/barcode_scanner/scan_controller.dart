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

  // Getters
  ScanState get scanState => _scanState.value;
  NutritionModel? get nutritionData => _nutritionData.value;
  String get errorMessage => _errorMessage.value;
  String get scannedBarcode => _scannedBarcode.value;
  
  bool get isIdle => _scanState.value == ScanState.idle;
  bool get isScanning => _scanState.value == ScanState.scanning;
  bool get isLoading => _scanState.value == ScanState.loading;
  bool get hasResult => _scanState.value == ScanState.result;
  bool get hasError => _scanState.value == ScanState.error;

  /// Start scanning - reset state and prepare for new scan
  void startScanning() {
    _scanState.value = ScanState.scanning;
    _errorMessage.value = '';
    _nutritionData.value = null;
    _scannedBarcode.value = '';
  }

  /// Handle barcode detection
  /// Validates barcode and fetches nutrition data
  Future<void> onBarcodeDetected(String barcode) async {
    try {
      // Validate barcode
      if (barcode.isEmpty || barcode.trim().isEmpty) {
        _setError('Invalid barcode');
        return;
      }

      // Prevent duplicate scans
      if (_scannedBarcode.value == barcode && _scanState.value == ScanState.loading) {
        return;
      }

      _scannedBarcode.value = barcode;
      _scanState.value = ScanState.loading;
      _errorMessage.value = '';

      // Fetch nutrition data
      final nutrition = await _nutritionService.fetchNutrition(barcode);

      if (nutrition != null) {
        _nutritionData.value = nutrition;
        _scanState.value = ScanState.result;
      } else {
        _setError('Product not found');
        _showSnackbar('Product not found', 'The barcode was not found in our database.');
      }
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      _setError(errorMsg);
      _showSnackbar('Error', errorMsg);
    }
  }

  /// Reset to idle state
  void reset() {
    _scanState.value = ScanState.idle;
    _nutritionData.value = null;
    _errorMessage.value = '';
    _scannedBarcode.value = '';
  }

  /// Rescan - go back to scanning state
  void rescan() {
    reset();
    startScanning();
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

