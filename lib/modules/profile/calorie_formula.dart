import 'profile_model.dart';

/// Calorie Calculation Service
/// Uses Mifflin-St Jeor equation for BMR calculation
class CalorieFormula {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  /// 
  /// Male: BMR = 10*weight + 6.25*height - 5*age + 5
  /// Female: BMR = 10*weight + 6.25*height - 5*age - 161
  static double calculateBMR({
    required double weight, // in kg
    required double height, // in cm
    required int age,
    required String gender, // 'Male' or 'Female'
  }) {
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    
    if (gender.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    
    return bmr;
  }

  /// Get activity multiplier based on activity level
  static double getActivityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'light':
      case 'lightly active':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'very active':
        return 1.725;
      default:
        return 1.2; // Default to sedentary
    }
  }

  /// Calculate daily maintenance calories
  /// dailyCalories = BMR * activityMultiplier
  static double calculateMaintenanceCalories({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );
    
    final multiplier = getActivityMultiplier(activityLevel);
    
    return bmr * multiplier;
  }

  /// Calculate goal calories based on weight goal
  /// 
  /// If targetWeight < currentWeight → calorie deficit (maintenance - 500)
  /// If targetWeight > currentWeight → calorie surplus (maintenance + 400)
  /// If targetWeight == currentWeight → maintenance calories
  static double calculateGoalCalories({
    required double maintenanceCalories,
    required double currentWeight,
    required double targetWeight,
  }) {
    if (targetWeight < currentWeight) {
      // Weight loss: 500 calorie deficit
      return maintenanceCalories - 500;
    } else if (targetWeight > currentWeight) {
      // Weight gain: 400 calorie surplus
      return maintenanceCalories + 400;
    } else {
      // Maintain weight: maintenance calories
      return maintenanceCalories;
    }
  }

  /// Calculate all calories for a profile
  static Map<String, double> calculateCalories({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double targetWeight,
  }) {
    final maintenance = calculateMaintenanceCalories(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
    );

    final goal = calculateGoalCalories(
      maintenanceCalories: maintenance,
      currentWeight: weight,
      targetWeight: targetWeight,
    );

    return {
      'maintenance': maintenance,
      'goal': goal,
    };
  }
}

