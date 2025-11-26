import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nutrition_model.dart';

/// Service class for fetching nutrition data from OpenFoodFacts API
class NutritionService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  /// Fetches nutrition data for a given barcode
  /// Returns null if product not found or on error
  Future<NutritionModel?> fetchNutrition(String barcode) async {
    try {
      // Validate barcode
      if (barcode.isEmpty || barcode.trim().isEmpty) {
        throw Exception('Invalid barcode: barcode is empty');
      }

      // Clean barcode (remove any whitespace)
      final cleanBarcode = barcode.trim();

      // Construct API URL
      final url = Uri.parse('$_baseUrl/$cleanBarcode.json');

      // Make GET request
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: No internet connection');
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        // Check if product exists
        final status = jsonData['status'] as int?;
        if (status == 0) {
          // Product not found
          return null;
        }

        // Parse and return nutrition model
        return NutritionModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // Product not found
        return null;
      } else {
        // Other HTTP errors
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      // Network errors (no internet, DNS failure, etc.)
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      // JSON parsing errors
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      // Any other errors
      throw Exception('Error fetching nutrition data: ${e.toString()}');
    }
  }
}

