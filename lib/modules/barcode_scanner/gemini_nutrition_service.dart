import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import 'nutrition_model.dart';

/// Service class for fetching nutrition data from Gemini API as fallback
/// Uses AI to extract nutrition information from product name/barcode
/// Implements caching to ensure consistent results for the same barcode
class GeminiNutritionService {
  static const List<Map<String, dynamic>> modelConfigs = [
    {'name': 'gemini-2.5-flash-lite', 'useBeta': false},
    {'name': 'gemini-1.5-flash', 'useBeta': true},
    {'name': 'gemini-1.5-pro', 'useBeta': true},
    {'name': 'gemini-2.5-flash', 'useBeta': false},
  ];

  static const String _cachePrefix = 'barcode_cache_';
  static const int _cacheMaxAgeDays = 30; // Cache expires after 30 days

  String _getApiUrl(String modelName, {bool useBeta = false}) {
    final version = useBeta ? 'v1beta' : 'v1';
    return "https://generativelanguage.googleapis.com/$version/models/$modelName:generateContent";
  }

  /// Fetch nutrition data using Gemini AI based on barcode/product name
  /// Uses caching to ensure consistent results for the same barcode
  Future<NutritionModel?> fetchNutritionFromGemini(
    String barcode, {
    String? productName,
  }) async {
    try {
      // Check cache first if we have a valid barcode
      if (barcode != 'unknown' && barcode.isNotEmpty) {
        final cached = await _getCachedNutrition(barcode);
        if (cached != null) {
          debugPrint('Returning cached nutrition data for barcode: $barcode');
          return cached;
        }
      }

      final apiKey = ApiConfig.geminiApiKey;
      
      // Create prompt for Gemini
      final prompt = _createNutritionPrompt(barcode, productName);
      
      // Try different models
      for (final config in modelConfigs) {
        final modelName = config['name'] as String;
        final useBeta = config['useBeta'] as bool? ?? false;
        
        try {
          final url = _getApiUrl(modelName, useBeta: useBeta);
          debugPrint('Trying Gemini model: $modelName for nutrition data');
          
          final response = await http.post(
            Uri.parse('$url?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.0, // Zero temperature for maximum determinism (with caching, this ensures consistency)
                'topK': 1, // Only consider the most likely token
                'topP': 0.1, // Very low topP for deterministic results
                'maxOutputTokens': 1024,
              }
            }),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            String responseText = '';
            
            if (responseData['candidates'] != null) {
              final candidates = responseData['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final candidate = candidates[0];
                if (candidate['content'] != null) {
                  final content = candidate['content'];
                  if (content['parts'] != null) {
                    final parts = content['parts'] as List;
                    if (parts.isNotEmpty && parts[0]['text'] != null) {
                      responseText = parts[0]['text'] as String;
                    }
                  }
                }
              }
            }
            
            if (responseText.isNotEmpty) {
              // Parse Gemini response to extract nutrition data
              final nutrition =
                  _parseGeminiResponse(responseText, barcode, productName);
              if (nutrition != null) {
                // Only cache if we're confident it's correct
                // Check if response indicates high confidence
                final shouldCache = _shouldCacheResponse(responseText, barcode, productName);
                
                if (shouldCache && barcode != 'unknown' && barcode.isNotEmpty) {
                  await _cacheNutrition(barcode, nutrition);
                } else if (barcode != 'unknown' && barcode.isNotEmpty) {
                  debugPrint('Not caching result for barcode $barcode - low confidence or validation failed');
                }
                return nutrition;
              }
            }
          } else if (response.statusCode == 429 || response.statusCode == 404) {
            // Try next model
            continue;
          } else {
            debugPrint('Gemini API error: ${response.statusCode}');
            break;
          }
        } catch (e) {
          debugPrint('Error with Gemini model $modelName: $e');
          continue;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching nutrition from Gemini: $e');
      return null;
    }
  }

  /// Create prompt for Gemini to extract nutrition information
  String _createNutritionPrompt(String barcode, String? productName) {
    final hasBarcode = barcode != 'unknown' && barcode.isNotEmpty;
    final hasProductName = productName != null && productName.trim().isNotEmpty;
    
    if (hasBarcode) {
      // Ultra-strict mode for barcode lookup - must identify exact product with high confidence
      return """You are a barcode database expert. Your task is to identify the EXACT product from a barcode number.

Barcode: $barcode
${hasProductName ? 'Expected Product Name (verify this matches the barcode): $productName' : ''}

CRITICAL RULES - READ CAREFULLY:
1. Barcodes are unique identifiers - each barcode corresponds to ONE specific product
2. You MUST have HIGH CONFIDENCE that you know the exact product for this barcode
3. If you are NOT CERTAIN about the product, you MUST return an error
4. DO NOT guess, estimate, or provide similar products
5. DO NOT make up product names
6. DO NOT use generic names like "Milk", "Tea", "Chocolate Bar" - use the FULL specific product name
7. The product name must include brand name and full product description (e.g., "Nestle Everyday Milk 1L", not just "Milk")
8. If the provided product name doesn't match what you know about this barcode, return an error

VERIFICATION CHECKLIST:
- Can you identify the EXACT product for barcode $barcode? (Yes/No)
- Are you CERTAIN this is correct? (Yes/No)
- Does the product name include brand and full description? (Yes/No)

If ANY answer is "No", return: {"error": "Cannot identify product with confidence"}

If you are CERTAIN about the product, return JSON in this EXACT format (no markdown, no code blocks):
{
  "productName": "Full specific product name with brand (e.g., 'Nestle Everyday Milk 1L' or 'Lipton Yellow Label Tea 100g')",
  "brand": "Brand name",
  "calories": number or null,
  "fat": number or null,
  "carbs": number or null,
  "sugar": number or null,
  "protein": number or null,
  "sodium": number or null,
  "confidence": "high"
}

OR if uncertain:
{
  "error": "Cannot identify product with confidence"
}

Data format:
- Calories: kcal per 100g
- All nutrients: grams per 100g
- Sodium: grams per 100g (convert from mg by dividing by 1000)
- Use null for unknown values, NOT 0
- Return ONLY valid JSON, no explanations

REMEMBER: Only return product data if you are CERTAIN. When in doubt, return an error.

JSON:""";
    } else {
      // More flexible mode when only product name is provided
      return """You are a nutrition data expert. Provide accurate nutrition information for the following product.

Product Name: ${hasProductName ? productName : 'Unknown'}

Provide nutrition information per 100g in EXACT JSON format. Use realistic values based on the specific product type.

Required JSON format (no markdown, no code blocks, just pure JSON):
{
  "productName": "product name",
  "brand": "brand name or null",
  "calories": number or null,
  "fat": number or null,
  "carbs": number or null,
  "sugar": number or null,
  "protein": number or null,
  "sodium": number or null
}

Data format rules:
1. Calories must be in kcal (kilocalories) per 100g
2. All macronutrients (fat, carbs, sugar, protein) in grams per 100g
3. Sodium in GRAMS per 100g (if you have mg, divide by 1000)
4. Use null for unknown values, not 0
5. Return ONLY valid JSON, no explanations, no markdown

JSON:""";
    }
  }

  /// Parse Gemini's response to extract nutrition data
  NutritionModel? _parseGeminiResponse(
    String response,
    String barcode,
    String? productName,
  ) {
    try {
      // Try to extract JSON from response
      String jsonString = response.trim();
      
      // Remove markdown code blocks if present
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();
      
      // Try to find JSON object in the response
      final jsonStart = jsonString.indexOf('{');
      final jsonEnd = jsonString.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd + 1);
      }
      
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Check if Gemini returned an error (product not found)
      if (jsonData.containsKey('error')) {
        debugPrint('Gemini could not identify product for barcode: $barcode');
        return null;
      }
      
      // Extract nutrition data
      final extractedName = jsonData['productName'] as String?;
      
      // Validate that we got a product name
      if (extractedName == null || extractedName.trim().isEmpty) {
        debugPrint('Gemini response missing product name for barcode: $barcode');
        return null;
      }
      
      // Extract all nutrition data first
      final brand = jsonData['brand'] as String?;
      final calories = _parseDouble(jsonData['calories']);
      final fat = _parseDouble(jsonData['fat']);
      final carbs = _parseDouble(jsonData['carbs']);
      final sugar = _parseDouble(jsonData['sugar']);
      final protein = _parseDouble(jsonData['protein']);
      final sodium = _parseDouble(jsonData['sodium']);

      // Additional validation: Check if product name seems reasonable
      // Reject if it's too generic or seems like a placeholder
      final lowerName = extractedName.toLowerCase();
      final genericNames = ['unknown', 'product', 'item', 'food', 'unknown product'];
      if (genericNames.any((generic) => lowerName.contains(generic) && lowerName.length < 20)) {
        debugPrint('Gemini returned generic product name: $extractedName for barcode: $barcode');
        return null;
      }

      // Validate product name quality - must be specific and detailed
      // Reject if product name is too short or too generic
      if (extractedName.trim().length < 10) {
        debugPrint('Product name too short: $extractedName for barcode: $barcode');
        return null;
      }

      // Check if product name contains common generic words that suggest guessing
      final suspiciousPatterns = [
        'milk', 'tea', 'chocolate', 'snack', 'food', 'drink', 'beverage'
      ];
      final nameWords = lowerName.split(' ');
      final suspiciousCount = nameWords.where((word) => 
        suspiciousPatterns.contains(word) && nameWords.length <= 3
      ).length;
      
      // If name is very short and contains generic words, it's likely a guess
      // Still return it but mark it as low confidence (won't be cached)
      final confidenceValue = jsonData['confidence'] as String?;
      final hasLowConfidence = confidenceValue != null && confidenceValue.toLowerCase() != 'high';
      final isLowConfidence = (suspiciousCount > 0 && nameWords.length <= 3 && extractedName.length < 25) ||
                              hasLowConfidence;
      
      if (isLowConfidence) {
        debugPrint('Low confidence response for barcode: $barcode - will not cache');
        // Still return the result but it won't be cached
        return NutritionModel(
          productName: extractedName.trim(),
          brand: brand?.trim(),
          imageUrl: null,
          calories: calories,
          fat: fat,
          carbs: carbs,
          sugar: sugar,
          protein: protein,
          sodium: sodium,
          barcode: barcode != 'unknown' ? barcode : null,
          nutrientLevels: {},
          isFromGemini: true,
        );
      }
      
      // Validate that we have at least some nutrition data
      if (calories == null && fat == null && carbs == null && protein == null) {
        debugPrint('Gemini response missing all nutrition data for barcode: $barcode');
        return null;
      }
      
      // Create nutrition model
      return NutritionModel(
        productName: extractedName.trim(),
        brand: brand?.trim(),
        imageUrl: null, // Gemini doesn't provide images
        calories: calories,
        fat: fat,
        carbs: carbs,
        sugar: sugar,
        protein: protein,
        sodium: sodium,
        barcode: barcode != 'unknown' ? barcode : null,
        nutrientLevels: {}, // Gemini doesn't provide nutrient levels
        isFromGemini: true, // Mark as Gemini data
      );
    } catch (e) {
      debugPrint('Error parsing Gemini response: $e');
      debugPrint('Response was: $response');
      return null;
    }
  }

  /// Helper method to parse double values
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Determine if a response should be cached based on confidence and quality
  bool _shouldCacheResponse(String response, String barcode, String? productName) {
    try {
      // Extract JSON from response to check confidence
      String jsonString = response.trim();
      
      // Remove markdown code blocks if present
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();
      
      // Try to find JSON object in the response
      final jsonStart = jsonString.indexOf('{');
      final jsonEnd = jsonString.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd + 1);
      }
      
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // If there's an error, don't cache
      if (jsonData.containsKey('error')) {
        return false;
      }
      
      // Check confidence level
      final confidence = jsonData['confidence'] as String?;
      if (confidence != null && confidence.toLowerCase() != 'high') {
        return false;
      }
      
      // Check product name quality
      final productNameFromResponse = jsonData['productName'] as String?;
      if (productNameFromResponse == null || productNameFromResponse.trim().isEmpty) {
        return false;
      }
      
      final name = productNameFromResponse.trim();
      
      // Must be at least 15 characters for a proper product name
      if (name.length < 15) {
        return false;
      }
      
      // If user provided product name, verify it matches reasonably
      if (productName != null && productName.trim().isNotEmpty) {
        final userProductLower = productName.toLowerCase().trim();
        final responseProductLower = name.toLowerCase();
        
        // Check if key words from user product name appear in response
        final userWords = userProductLower.split(' ').where((w) => w.length > 3).toList();
        final matchingWords = userWords.where((word) => responseProductLower.contains(word)).length;
        
        // If less than 50% of key words match, don't cache (might be wrong product)
        if (userWords.isNotEmpty && matchingWords < (userWords.length * 0.5)) {
          debugPrint('Product name mismatch: user said "$productName" but got "$name"');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking cache eligibility: $e');
      // When in doubt, don't cache
      return false;
    }
  }

  /// Get cached nutrition data for a barcode
  Future<NutritionModel?> _getCachedNutrition(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$barcode';
      final cachedJson = prefs.getString(cacheKey);
      
      if (cachedJson == null) {
        return null;
      }

      final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
      
      // Check if cache is expired
      final cachedTimestamp = cachedData['timestamp'] as int?;
      if (cachedTimestamp != null) {
        final cacheAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedTimestamp),
        );
        if (cacheAge.inDays > _cacheMaxAgeDays) {
          // Cache expired, remove it
          await prefs.remove(cacheKey);
          debugPrint('Cache expired for barcode: $barcode');
          return null;
        }
      }

      // Parse and return cached nutrition data
      final nutritionData = cachedData['nutrition'] as Map<String, dynamic>;
      return NutritionModel.fromSimpleJson(nutritionData);
    } catch (e) {
      debugPrint('Error reading cache for barcode $barcode: $e');
      return null;
    }
  }

  /// Cache nutrition data for a barcode
  Future<void> _cacheNutrition(String barcode, NutritionModel nutrition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$barcode';
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'nutrition': nutrition.toJson(),
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
      debugPrint('Cached nutrition data for barcode: $barcode');
    } catch (e) {
      debugPrint('Error caching nutrition for barcode $barcode: $e');
      // Don't throw - caching failure shouldn't break the app
    }
  }

  /// Clear cache for a specific barcode (optional utility method)
  Future<void> clearCacheForBarcode(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$barcode';
      await prefs.remove(cacheKey);
      debugPrint('Cleared cache for barcode: $barcode');
    } catch (e) {
      debugPrint('Error clearing cache for barcode $barcode: $e');
    }
  }

  /// Clear all cached nutrition data (optional utility method)
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix));
      
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
      
      debugPrint('Cleared all cached nutrition data (${cacheKeys.length} entries)');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }
}

