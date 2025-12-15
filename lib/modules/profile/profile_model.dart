/// User Profile Model
/// Contains user profile information and calculated calorie targets
class ProfileModel {
  final int age;
  final String gender; // 'Male' or 'Female'
  final double height; // in cm
  final double currentWeight; // in kg
  final double targetWeight; // in kg
  final String activityLevel; // 'Sedentary', 'Light', 'Moderate', 'Very Active'
  final double dailyCalories; // Calculated maintenance calories
  final double goalCalories; // Adjusted calories based on goal
  final bool hasBPIssue; // Blood pressure issue
  final bool hasDiabetes; // Diabetes condition
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.activityLevel,
    required this.dailyCalories,
    required this.goalCalories,
    this.hasBPIssue = false,
    this.hasDiabetes = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create ProfileModel from Firestore document
  factory ProfileModel.fromFirestore(Map<String, dynamic> data) {
    return ProfileModel(
      age: data['age'] as int,
      gender: data['gender'] as String,
      height: (data['height'] as num).toDouble(),
      currentWeight: (data['currentWeight'] as num).toDouble(),
      targetWeight: (data['targetWeight'] as num).toDouble(),
      activityLevel: data['activityLevel'] as String,
      dailyCalories: (data['dailyCalories'] as num).toDouble(),
      goalCalories: (data['goalCalories'] as num).toDouble(),
      hasBPIssue: data['hasBPIssue'] as bool? ?? false,
      hasDiabetes: data['hasDiabetes'] as bool? ?? false,
      createdAt: data['createdAt']?.toDate() as DateTime?,
      updatedAt: data['updatedAt']?.toDate() as DateTime?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'age': age,
      'gender': gender,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'dailyCalories': dailyCalories,
      'goalCalories': goalCalories,
      'hasBPIssue': hasBPIssue,
      'hasDiabetes': hasDiabetes,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  /// Create a copy with updated fields
  ProfileModel copyWith({
    int? age,
    String? gender,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? activityLevel,
    double? dailyCalories,
    double? goalCalories,
    bool? hasBPIssue,
    bool? hasDiabetes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      goalCalories: goalCalories ?? this.goalCalories,
      hasBPIssue: hasBPIssue ?? this.hasBPIssue,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

