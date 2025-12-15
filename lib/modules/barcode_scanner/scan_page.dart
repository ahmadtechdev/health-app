import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../colors.dart';
import '../food_diary/diary_controller.dart';
import 'nutrition_model.dart';
import 'scan_controller.dart';
import 'admin_product_form_page.dart';

/// Barcode Scanner Page
/// Scans barcodes and displays nutrition information from OpenFoodFacts
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late MobileScannerController _scannerController;
  late ScanController _scanController;
  late DiaryController _diaryController;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _scanController = Get.put(ScanController());
    if (Get.isRegistered<DiaryController>()) {
      _diaryController = Get.find<DiaryController>();
    } else {
      _diaryController = Get.put(DiaryController());
    }
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    final email = FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
    _isAdmin = email.contains('admin');
    // Start scanning when page loads
    _scanController.startScanning();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        // Stop scanner when not scanning
        if (!_scanController.isScanning && !_scanController.isIdle) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scannerController.stop();
          });
        }

        // Show different UI based on state
        if (_scanController.isScanning || _scanController.isIdle) {
          return _buildScannerView(_scanController);
        } else if (_scanController.isLoading) {
          return _buildLoadingView();
        } else if (_scanController.hasResult) {
          return _buildResultView(_scanController);
        } else if (_scanController.hasError) {
          return _buildErrorView(_scanController);
        }
        return _buildScannerView(_scanController);
      }),
      floatingActionButton:
          _isAdmin ? _buildAdminFab(context, _scanController) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAdminFab(BuildContext context, ScanController controller) {
    return FloatingActionButton.extended(
      onPressed: () => _openAdminForm(controller),
      backgroundColor: TColors.primary,
      foregroundColor: TColors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add product'),
    );
  }

  Future<void> _openAdminForm(ScanController controller) async {
    final result = await Get.to<NutritionModel?>(
      () => AdminProductFormPage(
        initialBarcode:
            controller.scannedBarcode.isNotEmpty ? controller.scannedBarcode : null,
        initialName: controller.nutritionData?.productName,
      ),
    );

    // If admin saved a product, refresh the flow so the user can see it immediately
    if (result?.barcode != null && result!.barcode!.isNotEmpty) {
      controller.rescan();
      controller.onBarcodeDetected(result.barcode!);
    }
  }

  /// Build scanner view with camera
  Widget _buildScannerView(ScanController controller) {
    // Start scanner when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scannerController.start();
    });

    return Stack(
      children: [
        // Camera scanner
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && controller.isScanning) {
              final barcode = barcodes.first;
              if (barcode.rawValue != null) {
                controller.onBarcodeDetected(barcode.rawValue!);
              }
            }
          },
        ),
        // Overlay with scanning box
        _buildScanningOverlay(),
        // Instructions
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildInstructions(),
        ),
      ],
    );
  }

  /// Build scanning overlay with box
  Widget _buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: CustomPaint(
        painter: ScannerOverlayPainter(),
        child: Container(),
      ),
    );
  }

  /// Build instructions text
  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.greyLight.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.barcodeScan,
            color: TColors.primary,
            size: 16,
          ),
          const SizedBox(width: 12),
              const Text(
                'Position barcode or enter product name',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: TColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }

  /// Build loading view with shimmer
  Widget _buildLoadingView() {
    return Container(
      color: TColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: TColors.greyLight,
              highlightColor: TColors.white,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: TColors.greyLight,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: TColors.greyLight,
              highlightColor: TColors.white,
              child: Container(
                width: 250,
                height: 20,
                decoration: BoxDecoration(
                  color: TColors.greyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Shimmer.fromColors(
              baseColor: TColors.greyLight,
              highlightColor: TColors.white,
              child: Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: TColors.greyLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing product with AI...',
              style: TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build result view with nutrition information
  Widget _buildResultView(ScanController controller) {
    final nutrition = controller.nutritionData!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Product Image
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TColors.primary, TColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: nutrition.imageUrl != null
                ? Image.network(
                    nutrition.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
          // Product Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TColors.greyLight.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI-powered data indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [TColors.primary.withOpacity(0.1), TColors.accent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TColors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.robot,
                        size: 16,
                        color: TColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI-Powered Nutrition Data',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Name
                Text(
                  nutrition.productName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TColors.textPrimary,
                  ),
                ),
                if (nutrition.brand != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    nutrition.brand!,
                    style: TextStyle(
                      fontSize: 16,
                      color: TColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Health Impact Analysis
                _buildHealthImpactSection(nutrition),
                const SizedBox(height: 24),
                // Calories (per 100g)
                if (nutrition.calories != null)
                  _buildNutritionRow(
                    icon: MdiIcons.fire,
                    label: 'Calories (per 100g)',
                    value: '${nutrition.calories!.toStringAsFixed(0)} kcal',
                    color: Colors.orange,
                  ),
                const SizedBox(height: 16),
                // Macronutrients
                _buildMacronutrientsSection(nutrition),
                const SizedBox(height: 24),
                // Nutrient Levels
                if (nutrition.nutrientLevels.isNotEmpty)
                  _buildNutrientLevelsSection(nutrition),
                const SizedBox(height: 24),
                // Diary summary
                _buildDiarySummary(_diaryController),
                const SizedBox(height: 24),
                // Action Buttons
                _buildActionButtons(controller, _diaryController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build placeholder image
  Widget _buildPlaceholderImage() {
    return Container(
      color: TColors.background3,
      child: Center(
        child: Icon(
          MdiIcons.food,
          size: 80,
          color: TColors.primary,
        ),
      ),
    );
  }

  /// Build nutrition row
  Widget _buildNutritionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: TColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.primary,
          ),
        ),
      ],
    );
  }

  /// Build macronutrients section
  Widget _buildMacronutrientsSection(NutritionModel nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Macronutrients (per 100g)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (nutrition.fat != null)
          _buildNutritionRow(
            icon: MdiIcons.water,
            label: 'Fat',
            value: '${nutrition.fat!.toStringAsFixed(1)}g',
            color: Colors.red,
          ),
        if (nutrition.carbs != null) ...[
          const SizedBox(height: 12),
          _buildNutritionRow(
            icon: MdiIcons.grain,
            label: 'Carbohydrates',
            value: '${nutrition.carbs!.toStringAsFixed(1)}g',
            color: Colors.blue,
          ),
        ],
        if (nutrition.protein != null) ...[
          const SizedBox(height: 12),
          _buildNutritionRow(
            icon: MdiIcons.dumbbell,
            label: 'Protein',
            value: '${nutrition.protein!.toStringAsFixed(1)}g',
            color: Colors.green,
          ),
        ],
        if (nutrition.sugar != null) ...[
          const SizedBox(height: 12),
          _buildNutritionRow(
            icon: MdiIcons.candy,
            label: 'Sugar',
            value: '${nutrition.sugar!.toStringAsFixed(1)}g',
            color: Colors.pink,
          ),
        ],
        if (nutrition.sodium != null) ...[
          const SizedBox(height: 12),
          _buildNutritionRow(
            icon: MdiIcons.bottleSoda,
            label: 'Sodium',
            value: '${nutrition.sodium!.toStringAsFixed(1)}g',
            color: Colors.purple,
          ),
        ],
      ],
    );
  }

  /// Build health impact analysis section
  Widget _buildHealthImpactSection(NutritionModel nutrition) {
    final healthAnalysis = _analyzeHealthImpact(nutrition);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.heartPulse,
              color: healthAnalysis['color'] as Color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Main health status card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (healthAnalysis['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: healthAnalysis['color'] as Color,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                healthAnalysis['icon'] as IconData,
                color: healthAnalysis['color'] as Color,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      healthAnalysis['status'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: healthAnalysis['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      healthAnalysis['message'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Detailed warnings/recommendations
        ...(healthAnalysis['warnings'] as List<Map<String, dynamic>>).map((warning) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (warning['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (warning['color'] as Color).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning['icon'] as IconData,
                    color: warning['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning['text'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: TColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Analyze health impact of the product
  Map<String, dynamic> _analyzeHealthImpact(NutritionModel nutrition) {
    final warnings = <Map<String, dynamic>>[];
    int healthScore = 0; // Positive = good, Negative = bad
    
    // Analyze calories
    if (nutrition.calories != null) {
      if (nutrition.calories! > 500) {
        healthScore -= 2;
        warnings.add({
          'text': 'Very high in calories (${nutrition.calories!.toStringAsFixed(0)} kcal/100g). Consume in moderation.',
          'color': TColors.error,
          'icon': MdiIcons.alertCircle,
        });
      } else if (nutrition.calories! > 400) {
        healthScore -= 1;
        warnings.add({
          'text': 'High in calories (${nutrition.calories!.toStringAsFixed(0)} kcal/100g). Watch your portion size.',
          'color': TColors.warning,
          'icon': MdiIcons.alert,
        });
      } else if (nutrition.calories! < 100) {
        healthScore += 1;
        warnings.add({
          'text': 'Low in calories (${nutrition.calories!.toStringAsFixed(0)} kcal/100g). Good for weight management.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      }
    }
    
    // Analyze sugar
    if (nutrition.sugar != null) {
      if (nutrition.sugar! > 20) {
        healthScore -= 3;
        warnings.add({
          'text': 'Very high in sugar (${nutrition.sugar!.toStringAsFixed(1)}g/100g). May cause blood sugar spikes.',
          'color': TColors.error,
          'icon': MdiIcons.alertCircle,
        });
      } else if (nutrition.sugar! > 15) {
        healthScore -= 2;
        warnings.add({
          'text': 'High in sugar (${nutrition.sugar!.toStringAsFixed(1)}g/100g). Limit consumption.',
          'color': TColors.warning,
          'icon': MdiIcons.alert,
        });
      } else if (nutrition.sugar! < 5) {
        healthScore += 1;
        warnings.add({
          'text': 'Low in sugar (${nutrition.sugar!.toStringAsFixed(1)}g/100g). Better for health.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      }
    }
    
    // Analyze fat
    if (nutrition.fat != null) {
      if (nutrition.fat! > 30) {
        healthScore -= 2;
        warnings.add({
          'text': 'Very high in fat (${nutrition.fat!.toStringAsFixed(1)}g/100g). May contribute to heart issues.',
          'color': TColors.error,
          'icon': MdiIcons.alertCircle,
        });
      } else if (nutrition.fat! > 20) {
        healthScore -= 1;
        warnings.add({
          'text': 'High in fat (${nutrition.fat!.toStringAsFixed(1)}g/100g). Consume moderately.',
          'color': TColors.warning,
          'icon': MdiIcons.alert,
        });
      } else if (nutrition.fat! < 5) {
        healthScore += 1;
        warnings.add({
          'text': 'Low in fat (${nutrition.fat!.toStringAsFixed(1)}g/100g). Healthier option.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      }
    }
    
    // Analyze sodium
    if (nutrition.sodium != null) {
      // Sodium is typically in grams, but we need to check if it's in mg
      // Open Food Facts provides sodium_100g in grams
      final sodiumGrams = nutrition.sodium!;
      final sodiumMg = sodiumGrams * 1000; // Convert to mg for comparison
      
      if (sodiumMg > 2000) {
        healthScore -= 3;
        warnings.add({
          'text': 'Very high in sodium (${sodiumMg.toStringAsFixed(0)}mg/100g). May increase blood pressure risk.',
          'color': TColors.error,
          'icon': MdiIcons.alertCircle,
        });
      } else if (sodiumMg > 1000) {
        healthScore -= 2;
        warnings.add({
          'text': 'High in sodium (${sodiumMg.toStringAsFixed(0)}mg/100g). Not ideal for heart health.',
          'color': TColors.warning,
          'icon': MdiIcons.alert,
        });
      } else if (sodiumMg < 400) {
        healthScore += 1;
        warnings.add({
          'text': 'Low in sodium (${sodiumMg.toStringAsFixed(0)}mg/100g). Better for blood pressure.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      }
    }
    
    // Analyze protein
    if (nutrition.protein != null) {
      if (nutrition.protein! > 15) {
        healthScore += 2;
        warnings.add({
          'text': 'High in protein (${nutrition.protein!.toStringAsFixed(1)}g/100g). Great for muscle health.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      } else if (nutrition.protein! > 10) {
        healthScore += 1;
        warnings.add({
          'text': 'Good protein content (${nutrition.protein!.toStringAsFixed(1)}g/100g). Supports body functions.',
          'color': TColors.success,
          'icon': MdiIcons.checkCircle,
        });
      }
    }
    
    // Check nutrient levels from API
    nutrition.nutrientLevels.forEach((key, value) {
      final level = value.toLowerCase();
      if (level == 'high') {
        if (key.toLowerCase().contains('fat') || 
            key.toLowerCase().contains('saturated') ||
            key.toLowerCase().contains('sugar') ||
            key.toLowerCase().contains('salt') ||
            key.toLowerCase().contains('sodium')) {
          healthScore -= 2;
          warnings.add({
            'text': 'High ${key} content detected. May impact health negatively.',
            'color': TColors.error,
            'icon': MdiIcons.alertCircle,
          });
        }
      } else if (level == 'medium') {
        if (key.toLowerCase().contains('fat') || 
            key.toLowerCase().contains('sugar') ||
            key.toLowerCase().contains('salt')) {
          healthScore -= 1;
          warnings.add({
            'text': 'Moderate ${key} content. Consume in moderation.',
            'color': TColors.warning,
            'icon': MdiIcons.alert,
          });
        }
      }
    });
    
    // Determine overall health status
    String status;
    Color color;
    IconData icon;
    String message;
    
    if (healthScore <= -3) {
      // Very unhealthy
      status = '⚠️ Not Recommended';
      color = TColors.error;
      icon = MdiIcons.alertCircle;
      message = 'This product has multiple health concerns. Consider healthier alternatives or consume very rarely.';
    } else if (healthScore <= -1) {
      // Unhealthy
      status = '⚠️ Use Caution';
      color = TColors.warning;
      icon = MdiIcons.alert;
      message = 'This product has some health concerns. Consume in moderation and balance with healthier foods.';
    } else if (healthScore >= 2) {
      // Healthy
      status = '✅ Good Choice';
      color = TColors.success;
      icon = MdiIcons.checkCircle;
      message = 'This product has good nutritional value. Fits well in a balanced diet.';
    } else {
      // Neutral
      status = '⚖️ Moderate';
      color = TColors.warning;
      icon = MdiIcons.information;
      message = 'This product is moderate in nutritional value. Can be part of a balanced diet in appropriate portions.';
    }
    
    return {
      'status': status,
      'color': color,
      'icon': icon,
      'message': message,
      'warnings': warnings,
      'score': healthScore,
    };
  }

  /// Build nutrient levels section
  Widget _buildNutrientLevelsSection(NutritionModel nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutrient Levels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...nutrition.nutrientLevels.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.textSecondary,
                    ),
                  ),
                ),
                _buildNutrientLevelBadge(entry.value),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Build nutrient level badge
  Widget _buildNutrientLevelBadge(String level) {
    Color color;
    switch (level.toLowerCase()) {
      case 'low':
        color = TColors.success;
        break;
      case 'medium':
        color = TColors.warning;
        break;
      case 'high':
        color = TColors.error;
        break;
      default:
        color = TColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Build diary summary card showing today's totals
  Widget _buildDiarySummary(DiaryController diaryController) {
    return Obx(() {
      final total = diaryController.totalCaloriesToday;
      final target = diaryController.targetCalories;
      final remaining = diaryController.remainingCalories;
      final over = diaryController.overCalories;
      final status = diaryController.status;
      final color = diaryController.statusColor;
      final hasTarget = diaryController.hasTarget;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.background3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.notebookOutline, color: TColors.primary),
                const SizedBox(width: 8),
                const Text(
                  "Today's Diary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Consumed",
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${total.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: TColors.background3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          over > 0 ? 'Over by' : 'Remaining',
                          style: const TextStyle(
                            fontSize: 13,
                            color: TColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          over > 0
                              ? '${over.toStringAsFixed(0)} kcal'
                              : '${remaining.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: over > 0 ? TColors.error : TColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasTarget)
              Text(
                'Complete your profile to get a personalized calorie target.',
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.warning,
                ),
              )
            else
              Text(
                'Target: ${target.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.textSecondary,
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Build action buttons
  Widget _buildActionButtons(
      ScanController controller, DiaryController diaryController) {
    final nutrition = controller.nutritionData;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.rescan,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: TColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(MdiIcons.barcodeScan, color: TColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Rescan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (diaryController.isAdding || nutrition == null)
                ? null
                : () => diaryController.addEntryFromNutrition(
                      nutrition,
                      controller.scannedBarcode.isNotEmpty
                          ? controller.scannedBarcode
                          : 'unknown',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (diaryController.isAdding) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(TColors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  Icon(MdiIcons.plusCircle, color: TColors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  diaryController.isAdding ? 'Saving...' : 'Add to Diary',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build error view
  Widget _buildErrorView(ScanController controller) {
    return _ErrorViewWidget(controller: controller);
  }
}

/// Error view widget with manual product name input
class _ErrorViewWidget extends StatefulWidget {
  final ScanController controller;
  
  const _ErrorViewWidget({required this.controller});
  
  @override
  State<_ErrorViewWidget> createState() => _ErrorViewWidgetState();
}

class _ErrorViewWidgetState extends State<_ErrorViewWidget> {
  late final TextEditingController _productNameController;
  
  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
  }
  
  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: TColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MdiIcons.alertCircle,
                size: 80,
                color: TColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                widget.controller.errorMessage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
                const Text(
                  'Enter the product name to get AI-powered nutrition information.',
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              // Manual product name input
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.greyLight.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., Coca Cola 500ml',
                        prefixIcon: const Icon(Icons.shopping_bag, color: TColors.primary),
                        filled: true,
                        fillColor: TColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: TColors.background3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: TColors.background3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TColors.primary, width: 2),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          widget.controller.fetchWithProductName(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_productNameController.text.isNotEmpty) {
                          widget.controller.fetchWithProductName(_productNameController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search, color: TColors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Get Nutrition Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: widget.controller.rescan,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  side: BorderSide(color: TColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.barcodeScan, color: TColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate scanning box dimensions
    final boxWidth = size.width * 0.7;
    final boxHeight = boxWidth * 0.6;
    final boxLeft = (size.width - boxWidth) / 2;
    final boxTop = (size.height - boxHeight) / 2 - 50;

    // Create hole in overlay
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight),
          const Radius.circular(16),
        ),
      );

    final scanPath = Path.combine(PathOperation.difference, path, hole);
    canvas.drawPath(scanPath, paint);

    // Draw border around scanning box
    final borderPaint = Paint()
      ..color = TColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight),
        const Radius.circular(16),
      ),
      borderPaint,
    );

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = TColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(boxLeft, boxTop + cornerLength),
      Offset(boxLeft, boxTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(boxLeft, boxTop),
      Offset(boxLeft + cornerLength, boxTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(boxLeft + boxWidth - cornerLength, boxTop),
      Offset(boxLeft + boxWidth, boxTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(boxLeft + boxWidth, boxTop),
      Offset(boxLeft + boxWidth, boxTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(boxLeft, boxTop + boxHeight - cornerLength),
      Offset(boxLeft, boxTop + boxHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(boxLeft, boxTop + boxHeight),
      Offset(boxLeft + cornerLength, boxTop + boxHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(boxLeft + boxWidth - cornerLength, boxTop + boxHeight),
      Offset(boxLeft + boxWidth, boxTop + boxHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(boxLeft + boxWidth, boxTop + boxHeight - cornerLength),
      Offset(boxLeft + boxWidth, boxTop + boxHeight),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

