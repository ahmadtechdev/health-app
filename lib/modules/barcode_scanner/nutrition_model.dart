/// Nutrition Model for OpenFoodFacts API response
/// Contains all nutrition information for a scanned product
class NutritionModel {
  final String productName;
  final String? brand;
  final String? imageUrl;
  final double? calories;
  final double? fat;
  final double? carbs;
  final double? sugar;
  final double? protein;
  final double? sodium;
  final Map<String, String> nutrientLevels; // e.g., {"fat": "high", "sugar": "medium"}

  NutritionModel({
    required this.productName,
    this.brand,
    this.imageUrl,
    this.calories,
    this.fat,
    this.carbs,
    this.sugar,
    this.protein,
    this.sodium,
    this.nutrientLevels = const {},
  });

  /// Factory constructor to create NutritionModel from JSON
  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      throw Exception('Product data not found in API response');
    }

    // Extract product name
    final productName = product['product_name'] as String? ?? 
                       product['product_name_en'] as String? ?? 
                       product['product_name_fr'] as String? ?? 
                       'Unknown Product';

    // Extract brand
    final brand = product['brands'] as String?;

    // Extract image URL
    final imageUrl = product['image_url'] as String? ?? 
                    product['image_front_url'] as String?;

    // Extract nutrition facts (per 100g)
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    
    // Calories (energy-kcal_100g or energy-kcal)
    final calories = _parseDouble(nutriments['energy-kcal_100g']) ?? 
                    _parseDouble(nutriments['energy-kcal']);

    // Fat (fat_100g)
    final fat = _parseDouble(nutriments['fat_100g']);

    // Carbohydrates (carbohydrates_100g)
    final carbs = _parseDouble(nutriments['carbohydrates_100g']);

    // Sugar (sugars_100g)
    final sugar = _parseDouble(nutriments['sugars_100g']);

    // Protein (proteins_100g)
    final protein = _parseDouble(nutriments['proteins_100g']);

    // Sodium (sodium_100g) - convert to mg if needed
    final sodium = _parseDouble(nutriments['sodium_100g']);

    // Extract nutrient levels
    final nutrientLevels = <String, String>{};
    final nutriscoreData = product['nutriscore_data'] as Map<String, dynamic>?;
    if (nutriscoreData != null) {
      final grades = nutriscoreData['grades'] as Map<String, dynamic>?;
      if (grades != null) {
        grades.forEach((key, value) {
          if (value is String) {
            nutrientLevels[key] = value;
          }
        });
      }
    }

    // Also check for nutrient_levels directly
    final nutrientLevelsDirect = product['nutrient_levels'] as Map<String, dynamic>?;
    if (nutrientLevelsDirect != null) {
      nutrientLevelsDirect.forEach((key, value) {
        if (value is String) {
          nutrientLevels[key] = value;
        }
      });
    }

    return NutritionModel(
      productName: productName,
      brand: brand,
      imageUrl: imageUrl,
      calories: calories,
      fat: fat,
      carbs: carbs,
      sugar: sugar,
      protein: protein,
      sodium: sodium,
      nutrientLevels: nutrientLevels,
    );
  }

  /// Helper method to parse double values from JSON
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Convert to JSON (for potential storage)
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'brand': brand,
      'imageUrl': imageUrl,
      'calories': calories,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'protein': protein,
      'sodium': sodium,
      'nutrientLevels': nutrientLevels,
    };
  }
}

