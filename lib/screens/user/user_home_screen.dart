import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../colors.dart';
import '../../widgets/app_bar_for_home.dart';
import '../admin/search_scan.dart';
import '../authentication/signin_screen.dart';
import '../chatBot.dart';
import '../treatment/home_treatment.dart';
import 'diet_fitness_screen_user.dart';
import 'userHospital/user_hospital_type.dart';
import 'user_doctor_category.dart';
import 'user_pharmacy.dart';
import '../../modules/barcode_scanner/scan_page.dart';
import '../../modules/profile/profile_page.dart';
import '../../modules/diary_dashboard/dashboard_page.dart';
import '../../modules/profile/profile_controller.dart';
import '../../modules/meal_planning/meal_planning_screen.dart';
import '../../widgets/user_bottom_nav_bar.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    _loadUserName();
    // Check profile and show dialog if incomplete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowProfileDialog();
    });
  }

  /// Load user name from Firebase Auth
  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Try to get display name first
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _userName = user.displayName!;
      } else if (user.email != null) {
        // Extract name from email (part before @)
        final emailParts = user.email!.split('@');
        final nameFromEmail = emailParts[0];
        // Capitalize first letter
        _userName = nameFromEmail[0].toUpperCase() + 
                   (nameFromEmail.length > 1 ? nameFromEmail.substring(1) : '');
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: TColors.background,
        boxShadow: [
          BoxShadow(
            color: TColors.greyLight.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $_userName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome to MediCare',
                style: TextStyle(
                  fontSize: 16,
                  color: TColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.logout, color: TColors.accent),
                onPressed: _showLogoutDialog,
                tooltip: 'Logout',
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildFeatureBanner(),
            const SizedBox(height: 24),
            _buildSectionHeader('Quick Access'),
            const SizedBox(height: 16),
            _buildQuickAccessGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader('Healthcare Services'),
            const SizedBox(height: 16),
            _buildHealthServicesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Get.to(() => SearchScan());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.white,
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
          children: [
            Icon(Icons.search, color: TColors.accent),
            const SizedBox(width: 12),
            Text(
              'Search ...',
              style: TextStyle(
                color: TColors.placeholder,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.camera_alt, color: TColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBanner() {
    return Container(
      height: 210,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/doctor3.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Need medical advice?',
                          style: TextStyle(
                            color: TColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get instant help from our MediGuide assistant',
                          style: TextStyle(
                            color: TColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => const ChatScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.white,
                            foregroundColor: TColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Chat Now'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Icon(
                        MdiIcons.robotOutline,
                        size: 70,
                        color: TColors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: TColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    List<Map<String, dynamic>> quickAccessItems = [
      {
        'icon': MdiIcons.pill,
        'title': 'Treatment',
        'color': Colors.orangeAccent,
        'onTap': () => Get.to(() => const ExampleAlarmHomeScreen()),
      },
      // {
      //   'icon': MdiIcons.hospital,
      //   'title': 'Hospitals',
      //   'color': Colors.blueAccent,
      //   'onTap': () => Get.to(() => UserHospitalType()),
      // },
      // {
      //   'icon': MdiIcons.doctor,
      //   'title': 'Doctors',
      //   'color': Colors.greenAccent.shade700,
      //   'onTap': () => Get.to(() => const UserDoctorCategory()),
      // },
      // {
      //   'icon': MdiIcons.medicalBag,
      //   'title': 'Pharmacy',
      //   'color': Colors.purpleAccent,
      //   'onTap': () => Get.to(() => const UserPharmacy()),
      // },
      {
        'icon': MdiIcons.account,
        'title': 'Profile',
        'color': TColors.primary,
        'onTap': () => Get.to(() => const ProfilePage()),
      },
      {
        'icon': MdiIcons.chartAreaspline,
        'title': 'Diary Dashboard',
        'color': Colors.teal,
        'onTap': () => Get.to(() => const DiaryDashboardPage()),
      },
      {
        'icon': MdiIcons.foodVariant,
        'title': 'Meal Plan',
        'color': Colors.orange,
        'onTap': () => Get.to(() => const MealPlanningScreen()),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: quickAccessItems.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 500),
          columnCount: 4,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: _buildQuickAccessItem(
                icon: quickAccessItems[index]['icon'],
                title: quickAccessItems[index]['title'],
                color: quickAccessItems[index]['color'],
                onTap: quickAccessItems[index]['onTap'],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(

        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: TColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthServicesGrid() {
    final services = [
      {
        'icon': MdiIcons.meditation,
        'title': 'Diet & Fitness',
        'description': 'Personalized plans for your health',
        'image': 'assets/images/diet_icon.png',
        'onTap': () => Get.to(() => FitnessPlanUser()),
      },
      {
        'icon': MdiIcons.foodVariant,
        'title': 'Meal Planning',
        'description': 'AI-powered personalized meal plans',
        'image': 'assets/images/diet.jpg',
        'onTap': () => Get.to(() => const MealPlanningScreen()),
      },
      {
        'icon': MdiIcons.robot,
        'title': 'MediGuide',
        'description': 'AI assistance for health queries',
        'image': 'assets/images/botimage.jpg',
        'onTap': () => Get.to(() => const ChatScreen()),
      },
      // {
      //   'icon': MdiIcons.cameraOutline,
      //   'title': 'Search by Scan',
      //   'description': 'Identify medicines with your camera',
      //   'image': 'assets/images/search&scan.jpg',
      //   'onTap': () => Get.to(() => SearchScan()),
      // },
      {
        'icon': MdiIcons.barcodeScan,
        'title': 'Search by Scan',
        'description': 'Scan food barcodes for nutrition info',
        'image': 'assets/images/search&scan.jpg',
        'onTap': () => Get.to(() => const ScanPage()),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildServiceCard(
                  icon: services[index]['icon'] as IconData,
                  title: services[index]['title'] as String,
                  description: services[index]['description'] as String,
                  image: services[index]['image'] as String,
                  onTap: services[index]['onTap'] as VoidCallback,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TColors.greyLight.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: TColors.accent.withOpacity(0.6),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        color: TColors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: TColors.accent,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return UserBottomNavBar(
      initialIndex: _selectedIndex,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const SignInScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error.withOpacity(0.9),
        colorText: TColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Check if profile exists and show dialog if incomplete
  Future<void> _checkAndShowProfileDialog() async {
    try {
      final profileController = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController(), permanent: true);

      await profileController.loadProfile();

      if (!profileController.hasProfile && mounted) {
        _showCompleteProfileDialog();
      }
    } catch (e) {
      // Silently handle errors - don't show dialog if there's an issue
      debugPrint('Error checking profile: $e');
    }
  }

  /// Show complete profile dialog
  void _showCompleteProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with dialog
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button from closing
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 48,
                      color: TColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Message
                  Text(
                    'To get personalized health recommendations and track your calorie goals, please complete your profile.',
                    style: TextStyle(
                      fontSize: 14,
                      color: TColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Later Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: TColors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Later',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Complete Profile Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.to(() => const ProfilePage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_forward, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Complete Now',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}