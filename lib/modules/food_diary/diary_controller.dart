import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_model.dart';
import '../barcode_scanner/nutrition_model.dart';
import 'diary_entry_model.dart';
import 'diary_service.dart';

class DiaryController extends GetxController {
  final DiaryService _service = DiaryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<DiaryEntryModel> _entries = <DiaryEntryModel>[].obs;
  final RxDouble _totalCalories = 0.0.obs;
  final RxDouble _targetCalories = 2000.0.obs;
  final RxBool _hasTarget = false.obs;
  final RxBool _isAdding = false.obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  StreamSubscription<List<DiaryEntryModel>>? _entriesSub;

  List<DiaryEntryModel> get entries => _entries;
  double get totalCaloriesToday => _totalCalories.value;
  double get targetCalories => _targetCalories.value;
  bool get hasTarget => _hasTarget.value;
  bool get isAdding => _isAdding.value;
  DateTime get selectedDate => _selectedDate.value;

  double get remainingCalories =>
      (targetCalories - totalCaloriesToday).clamp(0, double.infinity);

  double get overCalories =>
      totalCaloriesToday > targetCalories ? totalCaloriesToday - targetCalories : 0;

  String get status {
    if (totalCaloriesToday <= targetCalories * 0.9) {
      return 'under';
    } else if (totalCaloriesToday >= targetCalories * 1.1) {
      return 'over';
    } else {
      return 'normal';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'under':
        return TColors.warning;
      case 'over':
        return TColors.error;
      default:
        return TColors.success;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _entriesSub?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    await _loadTargetCalories();
    _listenToEntries();
  }

  Future<void> _loadTargetCalories() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Try to reuse existing profile controller if available
    ProfileModel? profile;
    if (Get.isRegistered<ProfileController>()) {
      profile = Get.find<ProfileController>().profile;
    }

    double? target;
    if (profile != null) {
      target = profile.goalCalories;
    } else {
      target = await _service.fetchTargetCalories(user.uid);
    }

    if (target != null && target > 0) {
      _targetCalories.value = target;
      _hasTarget.value = true;
    } else {
      _targetCalories.value = 2000;
      _hasTarget.value = false;
    }
  }

  void _listenToEntries() {
    final user = _auth.currentUser;
    if (user == null) return;

    _entriesSub?.cancel();
    _entriesSub = _service
        .watchEntries(userId: user.uid, date: _selectedDate.value)
        .listen((entries) {
      _entries.assignAll(entries);
      _totalCalories.value =
          entries.fold(0.0, (sum, entry) => sum + entry.calories);
    }, onError: (e) {
      _showError('Failed to load diary entries');
    });
  }

  Future<void> addEntryFromNutrition(
    NutritionModel nutrition,
    String barcode,
  ) async {
    if (nutrition.calories == null) {
      _showError('Calories info not available for this product');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _showError('Please sign in to add diary entries');
      return;
    }

    if (_isAdding.value) return;
    _isAdding.value = true;

    try {
      final entry = DiaryEntryModel(
        id: '',
        productName: nutrition.productName,
        calories: nutrition.calories ?? 0,
        timestamp: DateTime.now(),
        barcode: barcode,
        nutrientInfo: {
          'fat': nutrition.fat,
          'carbs': nutrition.carbs,
          'protein': nutrition.protein,
          'sugar': nutrition.sugar,
          'sodium': nutrition.sodium,
        }..removeWhere((key, value) => value == null),
      );

      await _service.addEntry(userId: user.uid, entry: entry);

      _showSuccess('Added to diary');
    } catch (e) {
      _showError('Failed to add diary entry');
    } finally {
      _isAdding.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.error.withOpacity(0.9),
      colorText: TColors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: TColors.white),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.success.withOpacity(0.9),
      colorText: TColors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: TColors.white),
    );
  }
}

