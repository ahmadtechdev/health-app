import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../user/diet_fitness_screen_user.dart';


class AddFitnessScreen extends StatefulWidget {
  const AddFitnessScreen({super.key});

  @override
  State<AddFitnessScreen> createState() => _AddFitnessScreenState();
}

class _AddFitnessScreenState extends State<AddFitnessScreen> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      var name = nameController.text.trim();
      var desc = descController.text.trim();

      try {
        // Query Firebase to check if a plan with the same title exists
        var existingPlan = await FirebaseFirestore.instance
            .collection("fitness")
            .where("title", isEqualTo: name)
            .get();

        if (existingPlan.docs.isNotEmpty) {
          _showFeedback(
            "Plan with this title already exists",
            TColors.error,
            Icons.error_outline,
          );
          setState(() => _isLoading = false);
        } else {
          // Add new fitness plan
          await FirebaseFirestore.instance
              .collection("fitness")
              .doc()
              .set({
            "createdAT": DateTime.now(),
            "userId": userId?.uid,
            "title": name,
            "desc": desc,
          }).then((value) {
            _showFeedback(
              "Plan successfully added!",
              TColors.success,
              Icons.check_circle_outline,
            );
            Future.delayed(const Duration(seconds: 1), () {
              Get.off(() => const FitnessPlanUser());
            });
          });
        }
      } catch (e) {
        _showFeedback(
          "Error occurred: ${e.toString()}",
          TColors.error,
          Icons.error_outline,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFeedback(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: TColors.white),
            const SizedBox(width: 10),
            Flexible(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: "Create Fitness Plan",
              backButton: true,
              signOutIcon: false,
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Animation container
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 10),
                        height: 200,
                        child: Lottie.asset(
                          "assets/Animation - fitness.json",
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                      // Content card
                      Container(
                        decoration: BoxDecoration(
                          color: TColors.background2,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: TColors.accent.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Plan Details",
                                style: TextStyle(
                                  color: TColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),

                              const SizedBox(height: 6),
                              Text(
                                "Create a new fitness and diet plan",
                                style: TextStyle(
                                  color: TColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ).animate().fadeIn(delay: 300.ms),

                              const SizedBox(height: 24),

                              // Title field with animation
                              _buildInputField(
                                controller: nameController,
                                label: "Plan Title",
                                hint: "Enter plan title",
                                icon: Icons.fitness_center,
                                isRequired: true,
                                animationDelay: 400,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a title";
                                  } else if (value.length < 3) {
                                    return "Title must be at least 3 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Description field with animation
                              _buildInputField(
                                controller: descController,
                                label: "Description",
                                hint: "Enter plan description",
                                icon: Icons.description_outlined,
                                isMultiline: true,
                                animationDelay: 600,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                      const SizedBox(height: 20),

                      // Submit button with loading state
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.accent,
                            foregroundColor: TColors.white,
                            elevation: 4,
                            shadowColor: TColors.accent.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: TColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "Create Plan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    bool isMultiline = false,
    int animationDelay = 0,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: TColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: TColors.textPrimary,
                ),
              ),
              if (isRequired)
                const Text(
                  " *",
                  style: TextStyle(
                    color: TColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: isMultiline ? 4 : 1,
          style: const TextStyle(
            color: TColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TColors.placeholder,
              fontSize: 15,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isMultiline ? 16 : 12,
            ),
            fillColor: TColors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TColors.greyLight.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TColors.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: TColors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: animationDelay)).slideX(begin: 0.1, end: 0);
  }
}