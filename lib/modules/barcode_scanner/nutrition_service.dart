import 'package:flutter/material.dart';
import 'nutrition_model.dart';
import 'gemini_nutrition_service.dart';

/// Service class for fetching nutrition data using Gemini AI
/// Uses AI to extract nutrition information from product name/barcode
class NutritionService {
  final GeminiNutritionService _geminiService = GeminiNutritionService();

  /// Fetches nutrition data using Gemini AI
  /// Can work with barcode, product name, or both
  /// Returns null if unable to fetch data
  Future<NutritionModel?> fetchNutrition(String identifier, {String? productName}) async {
    try {
      // Validate input
      if ((identifier.isEmpty || identifier.trim().isEmpty) && 
          (productName == null || productName.trim().isEmpty)) {
        throw Exception('Please provide either a barcode or product name');
      }

      debugPrint('Fetching nutrition data from Gemini API...');
      
      // Use Gemini to fetch nutrition data
      final nutrition = await _geminiService.fetchNutritionFromGemini(
        identifier.trim(),
        productName: productName?.trim(),
      );
      
      if (nutrition != null) {
        debugPrint('Successfully fetched nutrition data from Gemini API');
        return nutrition;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching nutrition data: $e');
      throw Exception('Error fetching nutrition data: ${e.toString()}');
    }
  }
}

