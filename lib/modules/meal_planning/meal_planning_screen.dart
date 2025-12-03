import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../colors.dart';
import '../../config/api_config.dart';
import '../profile/profile_controller.dart';

/// Meal Planning Chat Screen
/// Allows users to generate personalized meal plans based on their profile or manual input
class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  TextEditingController _userInput = TextEditingController();
  
  // Model configurations
  static const List<Map<String, dynamic>> modelConfigs = [
    {'name': 'gemini-2.5-flash-lite', 'useBeta': false},
    {'name': 'gemini-1.5-flash', 'useBeta': true},
    {'name': 'gemini-1.5-pro', 'useBeta': true},
    {'name': 'gemini-2.5-flash', 'useBeta': false},
    {'name': 'gemini-2.5-pro', 'useBeta': false},
  ];
  
  final List<Message> _messages = [];
  bool _isRequestInProgress = false;
  String? _workingModel;
  bool _useProfileData = false;
  bool _dataLoaded = false;
  
  // User data (from profile or manual)
  int? _age;
  String? _gender;
  double? _height;
  double? _currentWeight;
  double? _targetWeight;
  String? _activityLevel;
  bool _hasBPIssue = false;
  bool _hasDiabetes = false;
  double? _goalCalories;

  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    _checkProfileData();
  }

  @override
  void dispose() {
    _userInput.dispose();
    super.dispose();
  }

  /// Check if profile data exists
  Future<void> _checkProfileData() async {
    await _profileController.loadProfile();
    if (_profileController.hasProfile) {
      final profile = _profileController.profile!;
      setState(() {
        _age = profile.age;
        _gender = profile.gender;
        _height = profile.height;
        _currentWeight = profile.currentWeight;
        _targetWeight = profile.targetWeight;
        _activityLevel = profile.activityLevel;
        _hasBPIssue = profile.hasBPIssue;
        _hasDiabetes = profile.hasDiabetes;
        _goalCalories = profile.goalCalories;
        _dataLoaded = true;
      });
      
      // Add welcome message with option to use profile
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Welcome to Meal Planning Assistant! 👋\n\nI can help you create a personalized meal plan. Would you like to use your profile data or enter information manually?",
          date: DateTime.now(),
        ));
      });
    } else {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Welcome to Meal Planning Assistant! 👋\n\nI'll help you create a personalized meal plan. Please provide your information or I can guide you through the process.",
          date: DateTime.now(),
        ));
      });
    }
  }

  String _getApiUrl(String modelName, {bool useBeta = false}) {
    final version = useBeta ? 'v1beta' : 'v1';
    return "https://generativelanguage.googleapis.com/$version/models/$modelName:generateContent";
  }

  /// Show data input dialog
  void _showDataInputDialog() {
    final ageController = TextEditingController(text: _age?.toString() ?? '');
    final heightController = TextEditingController(text: _height?.toString() ?? '');
    final currentWeightController = TextEditingController(text: _currentWeight?.toString() ?? '');
    final targetWeightController = TextEditingController(text: _targetWeight?.toString() ?? '');
    String selectedGender = _gender ?? 'Male';
    String selectedActivityLevel = _activityLevel ?? 'Sedentary';
    bool hasBP = _hasBPIssue;
    bool hasDiabetes = _hasDiabetes;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
            decoration: BoxDecoration(
              color: TColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TColors.primary, TColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: TColors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Your Information',
                              style: TextStyle(
                                color: TColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Help us create your personalized meal plan',
                              style: TextStyle(
                                color: TColors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: TColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        _buildSectionHeader('Personal Information', Icons.person),
                        const SizedBox(height: 16),
                        
                        // Age
                        _buildTextField(
                          controller: ageController,
                          label: 'Age',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          hint: 'Enter your age',
                        ),
                        const SizedBox(height: 16),
                        
                        // Gender
                        _buildDropdownField<String>(
                          value: selectedGender,
                          label: 'Gender',
                          icon: Icons.people,
                          items: ['Male', 'Female'],
                          onChanged: (value) {
                            setDialogState(() => selectedGender = value ?? 'Male');
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Height
                        _buildTextField(
                          controller: heightController,
                          label: 'Height (cm)',
                          icon: Icons.height,
                          keyboardType: TextInputType.number,
                          hint: 'Enter height in cm',
                        ),
                        const SizedBox(height: 16),
                        
                        // Physical Information Section
                        _buildSectionHeader('Physical Information', Icons.fitness_center),
                        const SizedBox(height: 16),
                        
                        // Current Weight
                        _buildTextField(
                          controller: currentWeightController,
                          label: 'Current Weight (kg)',
                          icon: MdiIcons.weightKilogram,
                          keyboardType: TextInputType.number,
                          hint: 'Enter current weight',
                        ),
                        const SizedBox(height: 16),
                        
                        // Target Weight
                        _buildTextField(
                          controller: targetWeightController,
                          label: 'Target Weight (kg)',
                          icon: MdiIcons.target,
                          keyboardType: TextInputType.number,
                          hint: 'Enter target weight',
                        ),
                        const SizedBox(height: 16),
                        
                        // Activity Level
                        _buildDropdownField<String>(
                          value: selectedActivityLevel,
                          label: 'Activity Level',
                          icon: Icons.directions_run,
                          items: ['Sedentary', 'Light', 'Moderate', 'Very Active'],
                          onChanged: (value) {
                            setDialogState(() => selectedActivityLevel = value ?? 'Sedentary');
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Health Conditions Section
                        _buildSectionHeader('Health Conditions', Icons.health_and_safety),
                        const SizedBox(height: 16),
                        
                        // BP Issue
                        _buildHealthConditionCheckbox(
                          title: 'Blood Pressure Issues',
                          icon: MdiIcons.heartPulse,
                          value: hasBP,
                          onChanged: (value) => setDialogState(() => hasBP = value ?? false),
                        ),
                        const SizedBox(height: 12),
                        
                        // Diabetes
                        _buildHealthConditionCheckbox(
                          title: 'Diabetes / Sugar',
                          icon: MdiIcons.needle,
                          value: hasDiabetes,
                          onChanged: (value) => setDialogState(() => hasDiabetes = value ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    border: Border(
                      top: BorderSide(color: TColors.background3, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: TColors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _age = int.tryParse(ageController.text);
                              _height = double.tryParse(heightController.text);
                              _currentWeight = double.tryParse(currentWeightController.text);
                              _targetWeight = double.tryParse(targetWeightController.text);
                              _gender = selectedGender;
                              _activityLevel = selectedActivityLevel;
                              _hasBPIssue = hasBP;
                              _hasDiabetes = hasDiabetes;
                              _useProfileData = false;
                              _dataLoaded = true;
                            });
                            Navigator.pop(context);
                            _generateMealPlan();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restaurant_menu, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Generate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: TColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String hint,
  }) {
    return TextField(
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
        fillColor: TColors.white,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: TColors.accent),
        filled: true,
        fillColor: TColors.white,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(
        color: TColors.textPrimary,
        fontSize: 16,
      ),
    );
  }

  Widget _buildHealthConditionCheckbox({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? TColors.primary.withOpacity(0.1)
              : TColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? TColors.primary : TColors.background3,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value
                    ? TColors.primary.withOpacity(0.2)
                    : TColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: value ? TColors.primary : TColors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: value ? FontWeight.bold : FontWeight.normal,
                  color: value ? TColors.primary : TColors.textSecondary,
                ),
              ),
            ),
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: TColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Generate meal plan
  Future<void> _generateMealPlan() async {
    if (!_dataLoaded || _age == null || _height == null || _currentWeight == null || _targetWeight == null) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Please provide all required information first. Use the 'Enter Data' button or select 'Use Profile Data'.",
          date: DateTime.now(),
        ));
      });
      return;
    }

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: "Generate a personalized meal plan for me",
        date: DateTime.now(),
      ));
      _isRequestInProgress = true;
      _messages.add(Message(
        isUser: false,
        message: "Meal Planner is creating your personalized meal plan...",
        date: DateTime.now(),
        isTemporary: true,
      ));
    });

    // Build prompt with user data
    final weightGoal = _targetWeight! > _currentWeight! 
        ? "weight gain" 
        : _targetWeight! < _currentWeight! 
            ? "weight loss" 
            : "weight maintenance";
    
    final healthConditions = [];
    if (_hasBPIssue) healthConditions.add("high blood pressure");
    if (_hasDiabetes) healthConditions.add("diabetes");
    
    final prompt = """Create a comprehensive 7-day personalized meal plan for a ${_age}-year-old ${_gender?.toLowerCase()} with the following details:
- Height: ${_height} cm
- Current Weight: ${_currentWeight} kg
- Target Weight: ${_targetWeight} kg
- Goal: ${weightGoal}
- Activity Level: ${_activityLevel}
- Daily Calorie Target: ${_goalCalories?.toStringAsFixed(0) ?? 'calculated based on goal'} kcal
${healthConditions.isNotEmpty ? '- Health Conditions: ${healthConditions.join(', ')}' : ''}

Please provide:
1. A detailed 7-day meal plan with breakfast, lunch, dinner, and 2 snacks per day
2. Specific food items with portion sizes
3. Approximate calories per meal
4. Nutritional information (protein, carbs, fats)
5. Special dietary considerations based on health conditions
6. Meal prep tips and grocery shopping list

Format the response in a clear, organized structure with headings for each day. Make it practical and easy to follow.""";

    // Use cached working model if available
    Map<String, dynamic>? workingConfig;
    if (_workingModel != null) {
      workingConfig = modelConfigs.firstWhere(
        (config) => config['name'] == _workingModel,
        orElse: () => modelConfigs[0],
      );
    }
    
    final configsToTry = workingConfig != null ? [workingConfig] : modelConfigs;
    http.Response? lastResponse;
    String? lastError;
    
    for (final config in configsToTry) {
      final modelName = config['name'] as String;
      final useBeta = config['useBeta'] as bool? ?? false;
      
      try {
        final url = _getApiUrl(modelName, useBeta: useBeta);
        debugPrint('Trying model: $modelName (${useBeta ? "v1beta" : "v1"})');
        
        final response = await http.post(
          Uri.parse('$url?key=${ApiConfig.geminiApiKey}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 4096,
            }
          }),
        );

        lastResponse = response;
        
        if (response.statusCode == 200) {
          _workingModel = modelName;
          
          try {
            final responseData = jsonDecode(response.body);
            String responseText = "Sorry, I couldn't generate a meal plan.";
            
            if (responseData['candidates'] != null) {
              final candidates = responseData['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final candidate = candidates[0];
                if (candidate['content'] != null) {
                  final content = candidate['content'];
                  if (content['parts'] != null) {
                    final parts = content['parts'] as List;
                    if (parts.isNotEmpty && parts[0]['text'] != null) {
                      responseText = parts[0]['text'] as String;
                    }
                  }
                }
              }
            }

            setState(() {
              _messages.removeWhere((msg) => msg.isTemporary);
              _messages.add(Message(
                isUser: false,
                message: responseText,
                date: DateTime.now(),
                isMealPlan: true,
              ));
              _isRequestInProgress = false;
            });
            return;
          } catch (e) {
            debugPrint('Error parsing response: $e');
            lastError = "Failed to parse response: $e";
            continue;
          }
        } else {
          debugPrint('Response body: ${response.body}');
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['error'] != null) {
              final error = errorData['error'];
              lastError = error['message'] ?? error.toString();
              
              if (response.statusCode == 429 || response.statusCode == 404) {
                continue;
              } else if (response.statusCode == 400 || response.statusCode == 403 || response.statusCode == 401) {
                break;
              }
            }
          } catch (e) {
            lastError = response.body;
            if (response.statusCode == 404 || response.statusCode == 429) {
              continue;
            } else {
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('Exception caught for $modelName: $e');
        lastError = e.toString();
        continue;
      }
    }
    
    // If we get here, all models failed
    String errorMessage = "Error: Failed to generate meal plan. Please try again.";
    if (lastResponse != null) {
      try {
        final errorData = jsonDecode(lastResponse.body);
        if (errorData['error'] != null) {
          final error = errorData['error'];
          errorMessage = "Error: ${error['message'] ?? lastError ?? error.toString()}";
        }
      } catch (e) {
        errorMessage = "Error (${lastResponse.statusCode}): ${lastError ?? lastResponse.body}";
      }
    } else if (lastError != null) {
      errorMessage = "Error: $lastError";
    }
    
    setState(() {
      _messages.removeWhere((msg) => msg.isTemporary);
      _messages.add(Message(
        isUser: false,
        message: errorMessage,
        date: DateTime.now(),
      ));
      _isRequestInProgress = false;
    });
  }

  /// Share meal plan
  Future<void> _shareMealPlan(String mealPlanText) async {
    try {
      final shareText = '''
Personalized Meal Plan
Generated on: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}

$mealPlanText
''';
      
      await Share.share(
        shareText,
        subject: 'My Personalized Meal Plan',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share meal plan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error.withOpacity(0.9),
        colorText: TColors.white,
      );
    }
  }

  /// Copy meal plan to clipboard
  void _copyMealPlan(String mealPlanText) {
    Clipboard.setData(ClipboardData(text: mealPlanText));
    Get.snackbar(
      'Copied',
      'Meal plan copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.success.withOpacity(0.9),
      colorText: TColors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'Meal Planning Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_dataLoaded)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Use Profile Data',
              onPressed: () {
                _checkProfileData();
                setState(() {
                  _useProfileData = true;
                });
                _generateMealPlan();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Data selection buttons
          if (!_dataLoaded || !_useProfileData)
            Container(
              padding: const EdgeInsets.all(12),
              color: TColors.background2,
              child: Row(
                children: [
                  if (_profileController.hasProfile)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _useProfileData = true;
                          });
                          _generateMealPlan();
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Use Profile Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: TColors.white,
                        ),
                      ),
                    ),
                  if (_profileController.hasProfile) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showDataInputDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter Data'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TColors.primary),
                        foregroundColor: TColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MealPlanMessage(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                  isMealPlan: message.isMealPlan ?? false,
                  onShare: message.isMealPlan ?? false
                      ? () => _shareMealPlan(message.message)
                      : null,
                  onCopy: message.isMealPlan ?? false
                      ? () => _copyMealPlan(message.message)
                      : null,
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.white,
              boxShadow: [
                BoxShadow(
                  color: TColors.greyLight.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userInput,
                    style: const TextStyle(color: TColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask about meal planning...',
                      hintStyle: TextStyle(color: TColors.placeholder),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: TColors.background3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: TColors.background3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: TColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: const EdgeInsets.all(12),
                  iconSize: 28,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(TColors.primary),
                    foregroundColor: MaterialStateProperty.all(TColors.white),
                    shape: MaterialStateProperty.all(const CircleBorder()),
                  ),
                  onPressed: _isRequestInProgress ? null : () {
                    if (_userInput.text.isNotEmpty) {
                      sendMessage();
                    }
                  },
                  icon: _isRequestInProgress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
    });

    // Check if user wants to generate meal plan
    if (message.toLowerCase().contains('generate') || 
        message.toLowerCase().contains('meal plan') ||
        message.toLowerCase().contains('create')) {
      await _generateMealPlan();
    } else {
      // Handle other queries
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "To generate a meal plan, please use the buttons above to provide your information, or type 'generate meal plan'.",
          date: DateTime.now(),
        ));
      });
    }
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTemporary;
  final bool? isMealPlan;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
    this.isTemporary = false,
    this.isMealPlan,
  });
}

class MealPlanMessage extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final bool isMealPlan;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;

  const MealPlanMessage({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
    this.isMealPlan = false,
    this.onShare,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: TColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? TColors.primary : TColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.greyLight.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? TColors.white : TColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: isUser 
                              ? TColors.white.withOpacity(0.8) 
                              : TColors.textSecondary,
                        ),
                      ),
                      if (isMealPlan && !isUser) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              color: isUser ? TColors.white : TColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onCopy,
                              tooltip: 'Copy',
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.share, size: 18),
                              color: isUser ? TColors.white : TColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onShare,
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: TColors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

