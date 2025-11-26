import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../colors.dart';
import '../food_diary/diary_controller.dart';
import 'nutrition_model.dart';
import 'scan_controller.dart';

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
    );
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
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Position barcode within the frame',
            style: TextStyle(
              fontSize: 14,
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
              'Fetching nutrition data...',
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
                // Calories
                if (nutrition.calories != null)
                  _buildNutritionRow(
                    icon: MdiIcons.fire,
                    label: 'Calories',
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
    return Container(
      color: TColors.background,
      child: Center(
        child: Padding(
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
                controller.errorMessage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: controller.rescan,
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
                    Icon(MdiIcons.barcodeScan, color: TColors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Try Again',
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

