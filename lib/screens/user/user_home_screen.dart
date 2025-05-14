import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../colors.dart';
import '../../widgets/app_bar_for_home.dart';
import '../admin/search_scan.dart';
import '../chatBot.dart';
import '../treatment/home_treatment.dart';
import 'diet_fitness_screen_user.dart';
import 'userHospital/user_hospital_type.dart';
import 'user_doctor_category.dart';
import 'user_pharmacy.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
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
      bottomNavigationBar: _buildBottomNavBar(),
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
                'Hello, User',
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
                onPressed: () {
                  // Handle logout functionality
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Add your logout logic here
                              Navigator.of(context).pop();
                              // Navigate to login screen or perform logout
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {},
                child: Hero(
                  tag: 'profile',
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: TColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.accent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/profile_placeholder.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            backgroundColor: TColors.primary,
                            child: Text(
                              'U',
                              style: TextStyle(
                                color: TColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
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
      {
        'icon': MdiIcons.hospital,
        'title': 'Hospitals',
        'color': Colors.blueAccent,
        'onTap': () => Get.to(() => UserHospitalType()),
      },
      {
        'icon': MdiIcons.doctor,
        'title': 'Doctors',
        'color': Colors.greenAccent.shade700,
        'onTap': () => Get.to(() => const UserDoctorCategory()),
      },
      {
        'icon': MdiIcons.medicalBag,
        'title': 'Pharmacy',
        'color': Colors.purpleAccent,
        'onTap': () => Get.to(() => const UserPharmacy()),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
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
        'image': 'assets/images/diet.jpg',
        'onTap': () => Get.to(() => FitnessPlanUser()),
      },
      {
        'icon': MdiIcons.robot,
        'title': 'MediGuide',
        'description': 'AI assistance for health queries',
        'image': 'assets/images/botimage.jpg',
        'onTap': () => Get.to(() => const ChatScreen()),
      },
      {
        'icon': MdiIcons.cameraOutline,
        'title': 'Search by Scan',
        'description': 'Identify medicines with your camera',
        'image': 'assets/images/search&scan.jpg',
        'onTap': () => Get.to(() => SearchScan()),
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
        height: 110,
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
              Container(
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
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': MdiIcons.pill, 'label': 'Treatment'},
      {'icon': MdiIcons.hospitalBuilding, 'label': 'Hospitals'},
      {'icon': MdiIcons.doctor, 'label': 'Doctors'},
    ];

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.greyLight.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return InkWell(
            onTap: () => _onNavItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _selectedIndex == index ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: _selectedIndex == index
                    ? TColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: _selectedIndex == index
                        ? TColors.primary
                        : TColors.grey,
                    size: 24,
                  ),
                  if (_selectedIndex == index) ...[
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        color: TColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offAll(() => UserHome());
        break;
      case 1:
        Get.to(() => ExampleAlarmHomeScreen());
        break;
      case 2:
        Get.to(() => UserHospitalType());
        break;
      case 3:
        Get.to(() => UserDoctorCategory());
        break;
    }
  }
}