import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../colors.dart';
import 'profile_controller.dart';

/// Profile Page
/// Allows users to create/edit their profile and view calorie targets
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
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
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              const SizedBox(height: 24),

              // Profile Form
              _buildProfileForm(controller),
              const SizedBox(height: 24),

              // Calorie Target Display (if profile exists)
              if (controller.hasProfile) ...[
                _buildCalorieTargetCard(controller),
                const SizedBox(height: 24),
              ],

              // Save Button
              _buildSaveButton(controller),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  /// Build header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.accent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: TColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your goals and track your progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build profile form
  Widget _buildProfileForm(ProfileController controller) {
    return Container(
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
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Age
          _buildTextField(
            controller: controller.ageController,
            label: 'Age',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
            hint: 'Enter your age',
          ),
          const SizedBox(height: 16),

          // Gender
          _buildGenderSelector(controller),
          const SizedBox(height: 16),

          // Height
          _buildTextField(
            controller: controller.heightController,
            label: 'Height (cm)',
            icon: Icons.height,
            keyboardType: TextInputType.number,
            hint: 'Enter height in cm',
          ),
          const SizedBox(height: 16),

          // Current Weight
          _buildTextField(
            controller: controller.currentWeightController,
            label: 'Current Weight (kg)',
            icon: MdiIcons.weightKilogram,
            keyboardType: TextInputType.number,
            hint: 'Enter current weight',
          ),
          const SizedBox(height: 16),

          // Target Weight
          _buildTextField(
            controller: controller.targetWeightController,
            label: 'Target Weight (kg)',
            icon: MdiIcons.target,
            keyboardType: TextInputType.number,
            hint: 'Enter target weight',
          ),
          const SizedBox(height: 16),

          // Activity Level
          _buildActivityLevelSelector(controller),
        ],
      ),
    );
  }

  /// Build text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: TColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: TColors.accent),
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
          borderSide: const BorderSide(color: TColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Build gender selector
  Widget _buildGenderSelector(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: controller.genderOptions.map((gender) {
                final isSelected = controller.selectedGender == gender;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setGender(gender),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TColors.primary.withOpacity(0.1)
                            : TColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? TColors.primary : TColors.background3,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        gender,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? TColors.primary : TColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  /// Build activity level selector
  Widget _buildActivityLevelSelector(ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: controller.activityLevels.map((level) {
                final isSelected = controller.selectedActivityLevel == level;
                return GestureDetector(
                  onTap: () => controller.setActivityLevel(level),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TColors.primary.withOpacity(0.1)
                          : TColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? TColors.primary : TColors.background3,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? TColors.primary : TColors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? TColors.primary : TColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: TColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  /// Build calorie target card
  Widget _buildCalorieTargetCard(ProfileController controller) {
    if (controller.profile == null) return const SizedBox.shrink();

    final profile = controller.profile!;
    final isWeightLoss = profile.targetWeight < profile.currentWeight;
    final isWeightGain = profile.targetWeight > profile.currentWeight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.success.withOpacity(0.1), TColors.primary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.fire,
                color: TColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Calorie Targets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalorieRow(
            label: 'Maintenance Calories',
            value: '${profile.dailyCalories.toStringAsFixed(0)} kcal',
            icon: MdiIcons.scaleBalance,
            color: TColors.primary,
          ),
          const SizedBox(height: 12),
          _buildCalorieRow(
            label: 'Goal Calories',
            value: '${profile.goalCalories.toStringAsFixed(0)} kcal',
            icon: MdiIcons.target,
            color: isWeightLoss
                ? TColors.success
                : isWeightGain
                    ? TColors.warning
                    : TColors.primary,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.background3,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isWeightLoss
                      ? MdiIcons.trendingDown
                      : isWeightGain
                          ? MdiIcons.trendingUp
                          : MdiIcons.trendingNeutral,
                  color: isWeightLoss
                      ? TColors.success
                      : isWeightGain
                          ? TColors.warning
                          : TColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isWeightLoss
                        ? 'Weight Loss Goal: ${(profile.currentWeight - profile.targetWeight).toStringAsFixed(1)} kg to lose'
                        : isWeightGain
                            ? 'Weight Gain Goal: ${(profile.targetWeight - profile.currentWeight).toStringAsFixed(1)} kg to gain'
                            : 'Maintain Current Weight',
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build calorie row
  Widget _buildCalorieRow({
    required String label,
    required String value,
    required IconData icon,
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
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton(ProfileController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSaving ? null : () => controller.saveProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: TColors.primary.withOpacity(0.3),
            ),
            child: controller.isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        controller.hasProfile ? 'Update Profile' : 'Save Profile',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}

