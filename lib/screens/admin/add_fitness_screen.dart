import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import '../user/diet_fitness_screen_user.dart';

class AddFitnessScreen extends StatefulWidget {
  const AddFitnessScreen({super.key});

  @override
  State<AddFitnessScreen> createState() => _AddFitnessScreenState();
}

class _AddFitnessScreenState extends State<AddFitnessScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          "Add Fitness & Diet Plan",
          style: TextStyle(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [TColors.primary, TColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Share a category with users',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new plan',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Provide a short description to help users understand the category.',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: nameController,
                label: 'Title',
                hint: 'e.g., Summer Shred Program',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: descController,
                label: 'Short Description',
                hint: 'Quick overview of what this plan offers',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Plan',
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
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TColors.accent, width: 1.8),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = nameController.text.trim();
    final desc = descController.text.trim();

    try {
      final existing = await FirebaseFirestore.instance
          .collection("fitness")
          .where("title", isEqualTo: name)
          .get();

      if (existing.docs.isNotEmpty) {
        _showSnack("Title already exists", TColors.error);
        return;
      }

      await FirebaseFirestore.instance.collection("fitness").doc().set({
        "createdAT": DateTime.now(),
        "userId": userId?.uid,
        "title": name,
        "desc": desc,
      });

      _showSnack("Plan successfully added", TColors.success);
      Get.off(const FitnessPlanUser());
    } on FirebaseException catch (e) {
      String errorMessage = "Failed to add fitness plan";
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
          errorMessage = e.message ?? "Failed to add fitness plan. Please try again";
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
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
