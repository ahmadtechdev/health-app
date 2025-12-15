import 'package:flutter/material.dart';
import 'nutrition_model.dart';
import 'gemini_nutrition_service.dart';
import 'open_food_facts_service.dart';
import 'local_product_service.dart';

/// Service class for fetching nutrition data using Gemini AI
/// Uses AI to extract nutrition information from product name/barcode
class NutritionService {
  final GeminiNutritionService _geminiService = GeminiNutritionService();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();
  final LocalProductService _localProductService = LocalProductService();

  /// Fetches nutrition data using Gemini AI
  /// Can work with barcode, product name, or both
  /// Returns null if unable to fetch data
  Future<NutritionModel?> fetchNutrition(
    String identifier, {
    String? productName,
  }) async {
    try {
      // Validate input
      if ((identifier.isEmpty || identifier.trim().isEmpty) &&
          (productName == null || productName.trim().isEmpty)) {
        throw Exception('Please provide either a barcode or product name');
      }

      debugPrint('Fetching nutrition data from Gemini API...');

      final barcode = identifier.trim();
      final hasBarcode = barcode.isNotEmpty && barcode != 'unknown';
      final name = productName?.trim();

      // 1) Admin/local Firestore database first (barcode or name)
      if (hasBarcode) {
        final local = await _localProductService.getByBarcode(barcode);
        if (local != null) {
          debugPrint('Returning admin product for barcode $barcode');
          return local;
        }
      } else if (name != null && name.isNotEmpty) {
        final localByName = await _localProductService.getByName(name);
        if (localByName != null) {
          debugPrint('Returning admin product for name $name');
          return localByName;
        }
      }

      // 2) For barcode flow, try OpenFoodFacts then enrich with Gemini
      if (hasBarcode) {
        final openFood = await _openFoodFactsService.fetchByBarcode(barcode);
        if (openFood != null) {
          // Enrich with Gemini using the product name we got from OpenFoodFacts
          final geminiFromOpenFood =
              await _geminiService.fetchNutritionFromGemini(
            barcode,
            productName: openFood.productName,
          );

          if (geminiFromOpenFood != null) {
            debugPrint('Merged OpenFoodFacts + Gemini data for $barcode');
            // Merge image/brand from OpenFoodFacts if Gemini lacks it
            return geminiFromOpenFood.copyWith(
              imageUrl: geminiFromOpenFood.imageUrl ?? openFood.imageUrl,
              brand: geminiFromOpenFood.brand ?? openFood.brand,
              barcode: barcode,
            );
          }

          // Fallback to OpenFoodFacts data if Gemini enrichment fails
          return openFood;
        }

        // 3) Barcode not found in OpenFoodFacts -> return null
        // Don't try Gemini with barcode as it gives wrong results
        // User should search by product name instead
        debugPrint('Barcode $barcode not found in OpenFoodFacts');
        return null;
      }

      // 4) Name-only flow -> Gemini (after admin DB check above)
      return await _geminiService.fetchNutritionFromGemini(
        'unknown',
        productName: name,
      );
    } catch (e) {
      debugPrint('Error fetching nutrition data: $e');
      throw Exception('Error fetching nutrition data: ${e.toString()}');
    }
  }
}

