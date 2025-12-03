import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../colors.dart';
import 'calorie_formula.dart';
import 'profile_model.dart';

/// Profile Controller using GetX
/// Manages user profile state and Firebase operations
class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form controllers
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final currentWeightController = TextEditingController();
  final targetWeightController = TextEditingController();

  // Observable state
  final _profile = Rxn<ProfileModel>();
  final _isLoading = false.obs;
  final _isSaving = false.obs;
  final _selectedGender = 'Male'.obs;
  final _selectedActivityLevel = 'Sedentary'.obs;
  final _hasBPIssue = false.obs;
  final _hasDiabetes = false.obs;

  // Getters
  ProfileModel? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  String get selectedGender => _selectedGender.value;
  String get selectedActivityLevel => _selectedActivityLevel.value;
  bool get hasBPIssue => _hasBPIssue.value;
  bool get hasDiabetes => _hasDiabetes.value;
  bool get hasProfile => _profile.value != null;

  // Gender options
  final List<String> genderOptions = ['Male', 'Female'];

  // Activity level options
  final List<String> activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Very Active',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    ageController.dispose();
    heightController.dispose();
    currentWeightController.dispose();
    targetWeightController.dispose();
    super.onClose();
  }

  /// Set selected gender
  void setGender(String gender) {
    _selectedGender.value = gender;
  }

  /// Set selected activity level
  void setActivityLevel(String level) {
    _selectedActivityLevel.value = level;
  }

  /// Set BP issue status
  void setHasBPIssue(bool value) {
    _hasBPIssue.value = value;
  }

  /// Set diabetes status
  void setHasDiabetes(bool value) {
    _hasDiabetes.value = value;
  }

  /// Load user profile from Firestore
  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    _isLoading.value = true;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('data')
          .get();

      if (doc.exists && doc.data() != null) {
        _profile.value = ProfileModel.fromFirestore(doc.data()!);
        _populateForm();
      }
    } on FirebaseException catch (e) {
      String errorMessage = "Failed to load profile";
      switch (e.code) {
        case 'permission-denied':
          errorMessage = "You do not have permission to view this profile";
          break;
        case 'unavailable':
          errorMessage = "The service is currently unavailable. Please try again later";
          break;
        case 'deadline-exceeded':
          errorMessage = "The operation took too long. Please try again";
          break;
        default:
          errorMessage = e.message ?? "Failed to load profile. Please try again";
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Populate form fields with existing profile data
  void _populateForm() {
    if (_profile.value == null) return;

    final p = _profile.value!;
    ageController.text = p.age.toString();
    heightController.text = p.height.toString();
    currentWeightController.text = p.currentWeight.toString();
    targetWeightController.text = p.targetWeight.toString();
    _selectedGender.value = p.gender;
    _selectedActivityLevel.value = p.activityLevel;
    _hasBPIssue.value = p.hasBPIssue;
    _hasDiabetes.value = p.hasDiabetes;
  }

  /// Validate form inputs
  String? _validateForm() {
    // Age validation
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      return 'Please enter a valid age (1-120)';
    }

    // Height validation
    final height = double.tryParse(heightController.text.trim());
    if (height == null || height < 50 || height > 250) {
      return 'Please enter a valid height (50-250 cm)';
    }

    // Current weight validation
    final currentWeight = double.tryParse(currentWeightController.text.trim());
    if (currentWeight == null || currentWeight < 20 || currentWeight > 300) {
      return 'Please enter a valid current weight (20-300 kg)';
    }

    // Target weight validation
    final targetWeight = double.tryParse(targetWeightController.text.trim());
    if (targetWeight == null || targetWeight < 20 || targetWeight > 300) {
      return 'Please enter a valid target weight (20-300 kg)';
    }

    return null;
  }

  /// Save profile to Firestore
  Future<void> saveProfile() async {
    // Validate form
    final validationError = _validateForm();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    _isSaving.value = true;

    try {
      // Parse form values
      final age = int.parse(ageController.text.trim());
      final height = double.parse(heightController.text.trim());
      final currentWeight = double.parse(currentWeightController.text.trim());
      final targetWeight = double.parse(targetWeightController.text.trim());
      final gender = _selectedGender.value;
      final activityLevel = _selectedActivityLevel.value;
      final hasBPIssue = _hasBPIssue.value;
      final hasDiabetes = _hasDiabetes.value;

      // Calculate calories
      final calories = CalorieFormula.calculateCalories(
        weight: currentWeight,
        height: height,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        targetWeight: targetWeight,
      );

      // Create profile model
      final profile = ProfileModel(
        age: age,
        gender: gender,
        height: height,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        activityLevel: activityLevel,
        dailyCalories: calories['maintenance']!,
        goalCalories: calories['goal']!,
        hasBPIssue: hasBPIssue,
        hasDiabetes: hasDiabetes,
        createdAt: _profile.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('data')
          .set(profile.toFirestore());

      // Update local state
      _profile.value = profile;

      _showSuccess('Profile saved successfully!');
    } on FirebaseException catch (e) {
      String errorMessage = "Failed to save profile";
      switch (e.code) {
        case 'permission-denied':
          errorMessage = "You do not have permission to perform this operation";
          break;
        case 'unavailable':
          errorMessage = "The service is currently unavailable. Please try again later";
          break;
        case 'deadline-exceeded':
          errorMessage = "The operation took too long. Please try again";
          break;
        default:
          errorMessage = e.message ?? "Failed to save profile. Please try again";
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again');
    } finally {
      _isSaving.value = false;
    }
  }

  /// Show error snackbar
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
      icon: const Icon(
        Icons.error_outline,
        color: TColors.white,
      ),
    );
  }

  /// Show success snackbar
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
      icon: const Icon(
        Icons.check_circle_outline,
        color: TColors.white,
      ),
    );
  }
}

