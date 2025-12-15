import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nutrition_model.dart';

/// Fetches product data from the OpenFoodFacts public API.
class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  /// Lookup a product by barcode. Returns null when not found.
  Future<NutritionModel?> fetchByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;
    final uri = Uri.parse('$_baseUrl/$barcode.json');

    try {
      final response = await http.get(uri, headers: {
        // OpenFoodFacts requires a descriptive user agent
        'User-Agent': 'health-app/1.0 (+https://openfoodfacts.org)',
      }).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as int? ?? 0;
      if (status != 1) return null;

      return NutritionModel.fromOpenFoodJson(data, barcode: barcode);
    } catch (_) {
      return null;
    }
  }
}

