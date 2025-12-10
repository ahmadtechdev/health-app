import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import 'nutrition_model.dart';

/// Service class for fetching nutrition data from Gemini API as fallback
/// Uses AI to extract nutrition information from product name/barcode
class GeminiNutritionService {
  static const List<Map<String, dynamic>> modelConfigs = [
    {'name': 'gemini-2.5-flash-lite', 'useBeta': false},
    {'name': 'gemini-1.5-flash', 'useBeta': true},
    {'name': 'gemini-1.5-pro', 'useBeta': true},
    {'name': 'gemini-2.5-flash', 'useBeta': false},
  ];

  String _getApiUrl(String modelName, {bool useBeta = false}) {
    final version = useBeta ? 'v1beta' : 'v1';
    return "https://generativelanguage.googleapis.com/$version/models/$modelName:generateContent";
  }

  /// Fetch nutrition data using Gemini AI based on barcode/product name
  Future<NutritionModel?> fetchNutritionFromGemini(String barcode, {String? productName}) async {
    try {
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
                'temperature': 0.3, // Lower temperature for more accurate data
                'topK': 40,
                'topP': 0.95,
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
              final nutrition = _parseGeminiResponse(responseText, barcode, productName);
              if (nutrition != null) {
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
    return """You are a nutrition data expert. Extract accurate nutrition information for the following product.

${productName != null ? 'Product Name: $productName' : ''}
${barcode != 'unknown' ? 'Barcode: $barcode' : ''}

Provide nutrition information per 100g in EXACT JSON format. Use realistic values based on similar products if exact data is unavailable.

Required JSON format (no markdown, no code blocks, just pure JSON):
{
  "productName": "exact product name",
  "brand": "brand name or null",
  "calories": number or null,
  "fat": number or null,
  "carbs": number or null,
  "sugar": number or null,
  "protein": number or null,
  "sodium": number or null
}

Critical rules:
1. Calories must be in kcal (kilocalories) per 100g
2. All macronutrients (fat, carbs, sugar, protein) in grams per 100g
3. Sodium in GRAMS per 100g (if you have mg, divide by 1000)
4. Use null for unknown values, not 0
5. Provide realistic estimates for common products
6. Return ONLY valid JSON, no explanations, no markdown

Example for a chocolate bar:
{
  "productName": "Milk Chocolate Bar",
  "brand": null,
  "calories": 535,
  "fat": 30.5,
  "carbs": 57.5,
  "sugar": 54.0,
  "protein": 7.7,
  "sodium": 0.1
}

JSON:""";
  }

  /// Parse Gemini's response to extract nutrition data
  NutritionModel? _parseGeminiResponse(String response, String barcode, String? productName) {
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
      
      // Extract nutrition data
      final extractedName = jsonData['productName'] as String? ?? 
                           productName ?? 
                           'Unknown Product';
      final brand = jsonData['brand'] as String?;
      final calories = _parseDouble(jsonData['calories']);
      final fat = _parseDouble(jsonData['fat']);
      final carbs = _parseDouble(jsonData['carbs']);
      final sugar = _parseDouble(jsonData['sugar']);
      final protein = _parseDouble(jsonData['protein']);
      final sodium = _parseDouble(jsonData['sodium']);
      
      // Create nutrition model
      return NutritionModel(
        productName: extractedName,
        brand: brand,
        imageUrl: null, // Gemini doesn't provide images
        calories: calories,
        fat: fat,
        carbs: carbs,
        sugar: sugar,
        protein: protein,
        sodium: sodium,
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
}

