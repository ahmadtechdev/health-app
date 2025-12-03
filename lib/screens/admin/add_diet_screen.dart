import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../user/fitness_info_screen_user.dart';

class AddDietScreen extends StatefulWidget {
  const AddDietScreen({super.key});

  @override
  State<AddDietScreen> createState() => _AddDietScreenState();
}

class _AddDietScreenState extends State<AddDietScreen> {
  String fitnessTitle = Get.arguments['title'].toString();
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;
  final dietController = TextEditingController();
  final planController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: Text(
          'Add plan for $fitnessTitle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share a detailed routine or nutritional guideline for this category. Use headings starting with "#" and bullet points with "-".',
                style: const TextStyle(
                  color: TColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: dietController,
                label: 'Plan title',
                hint: 'e.g., Morning routine',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plan title';
                  }
                  if (value.length < 3) {
                    return 'Title should be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: planController,
                label: 'Plan details',
                hint: 'Add steps, meals, exercises, etc.',
                maxLines: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plan details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save plan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.accent, width: 1.8),
        ),
      ),
    );
  }

  Future<void> _savePlan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final planTitle = dietController.text.trim();
    final plan = planController.text.trim();

    try {
      final existing = await FirebaseFirestore.instance
          .collection("diet")
          .where("planTitle", isEqualTo: planTitle)
          .where("title", isEqualTo: fitnessTitle)
          .get();

      if (existing.docs.isNotEmpty) {
        _showSnack("Plan title already exists", TColors.error);
        return;
      }

      await FirebaseFirestore.instance.collection("diet").doc().set({
        "createdAT": DateTime.now(),
        "userId": userId?.uid,
        "title": fitnessTitle,
        "planTitle": planTitle,
        "plan": plan,
      });

      _showSnack("Plan added successfully", TColors.success);
      Get.back(result: true);
    } on FirebaseException catch (e) {
      String errorMessage = "Failed to add diet plan";
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
          errorMessage = e.message ?? "Failed to add diet plan. Please try again";
      }
      _showSnack(errorMessage, TColors.error);
    } catch (e) {
      _showSnack("An unexpected error occurred. Please try again", TColors.error);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
