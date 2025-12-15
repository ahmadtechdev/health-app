/// Nutrition Model for OpenFoodFacts API response
/// Contains all nutrition information for a scanned product
/// 
/// Energy Conversion:
/// - Open Food Facts API provides energy in kJ (kilojoules) by default
/// - Conversion formula: Kcal = kJ * 0.23900573614
/// - The API also provides energy-kcal_100g field directly in kcal
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
  final String? barcode;
  final Map<String, String> nutrientLevels; // e.g., {"fat": "high", "sugar": "medium"}
  final bool isFromGemini; // Indicates if data came from Gemini API

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
    this.barcode,
    this.nutrientLevels = const {},
    this.isFromGemini = false,
  });

  /// Factory constructor to create NutritionModel from JSON
  factory NutritionModel.fromOpenFoodJson(
    Map<String, dynamic> json, {
    String? barcode,
  }) {
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
    
    // Calories extraction with proper fallback and conversion
    // Priority order:
    // 1. energy-kcal_100g (preferred - direct kcal per 100g)
    // 2. energy-kcal (alternative kcal field)
    // 3. energy-kj_100g converted to kcal (kJ * 0.23900573614)
    // 4. energy-kj converted to kcal
    // 5. energy_100g (auto-detect if kJ or kcal)
    // 6. energy (auto-detect if kJ or kcal)
    double? calories;
    
    // Conversion constant: kJ to kcal
    const double kJToKcal = 0.23900573614;
    
    // First priority: energy-kcal_100g (direct kcal per 100g)
    calories = _parseDouble(nutriments['energy-kcal_100g']);
    
    // Second priority: energy-kcal (alternative kcal field)
    if (calories == null) {
      calories = _parseDouble(nutriments['energy-kcal']);
    }
    
    // Third priority: Convert from kJ (energy-kj_100g)
    if (calories == null) {
      final energyKj = _parseDouble(nutriments['energy-kj_100g']);
      if (energyKj != null && energyKj > 0) {
        calories = energyKj * kJToKcal;
      }
    }
    
    // Fourth priority: Convert from kJ (energy-kj)
    if (calories == null) {
      final energyKj = _parseDouble(nutriments['energy-kj']);
      if (energyKj != null && energyKj > 0) {
        calories = energyKj * kJToKcal;
      }
    }
    
    // Fifth priority: Try energy_100g (auto-detect unit)
    if (calories == null) {
      final energy = _parseDouble(nutriments['energy_100g']);
      if (energy != null && energy > 0) {
        // Typical food energy: kJ ranges 100-5000, kcal ranges 20-1200
        // If value > 1000, it's likely kJ, otherwise assume kcal
        if (energy > 1000) {
          calories = energy * kJToKcal;
        } else {
          calories = energy;
        }
      }
    }
    
    // Sixth priority: Try energy (without _100g suffix)
    if (calories == null) {
      final energy = _parseDouble(nutriments['energy']);
      if (energy != null && energy > 0) {
        // Auto-detect: if value > 1000, it's likely kJ
        if (energy > 1000) {
          calories = energy * kJToKcal;
        } else {
          calories = energy;
        }
      }
    }
    
    // Round to 1 decimal place for cleaner display
    if (calories != null) {
      calories = double.parse(calories!.toStringAsFixed(1));
    }

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
      barcode: barcode,
      nutrientLevels: nutrientLevels,
      isFromGemini: false,
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

  /// Factory constructor to create NutritionModel from simple JSON (for caching)
  factory NutritionModel.fromSimpleJson(Map<String, dynamic> json) {
    return NutritionModel(
      productName: json['productName'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
      calories: _parseDouble(json['calories']),
      fat: _parseDouble(json['fat']),
      carbs: _parseDouble(json['carbs']),
      sugar: _parseDouble(json['sugar']),
      protein: _parseDouble(json['protein']),
      sodium: _parseDouble(json['sodium']),
      nutrientLevels: (json['nutrientLevels'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          const {},
      isFromGemini: json['isFromGemini'] as bool? ?? false,
    );
  }

  /// Convert to JSON (for potential storage)
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'brand': brand,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'calories': calories,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'protein': protein,
      'sodium': sodium,
      'nutrientLevels': nutrientLevels,
      'isFromGemini': isFromGemini,
    };
  }

  /// Create a copy with selective overrides (useful for merging sources)
  NutritionModel copyWith({
    String? productName,
    String? brand,
    String? imageUrl,
    double? calories,
    double? fat,
    double? carbs,
    double? sugar,
    double? protein,
    double? sodium,
    String? barcode,
    Map<String, String>? nutrientLevels,
    bool? isFromGemini,
  }) {
    return NutritionModel(
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      protein: protein ?? this.protein,
      sodium: sodium ?? this.sodium,
      barcode: barcode ?? this.barcode,
      nutrientLevels: nutrientLevels ?? this.nutrientLevels,
      isFromGemini: isFromGemini ?? this.isFromGemini,
    );
  }
}

