
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/user_bottom_nav_bar.dart';
import '../user_doctor_category.dart';
import '../user_home_screen.dart';
import 'user_hospitals_private.dart';
import 'user_hospitals_public.dart';

class UserHospitalType extends StatefulWidget {
  const UserHospitalType({super.key});

  @override
  State<UserHospitalType> createState() => _UserHospitalTypeState();
}

class _UserHospitalTypeState extends State<UserHospitalType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: wColor),
          child: Column(
            children: [
              CustomAppBar(
                  title: "Hospital Types",
                  backButton: true,
                  signOutIcon: false,
                  backgroundColor: primary,
                  onBackButtonPressed: () {
                    // Navigate to a specific screen
                    Get.off(() => UserHome());
                  }),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildModuleContainer(
                        icon: Icons.private_connectivity,
                        image: 'assets/images/hospital.jpg',
                        title: 'Private',
                        onTap: () {
                          Get.to(() => UserHospitalsPrivate());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/doctors.jpg',
                        title: 'Public',
                        onTap: () {
                          Get.to(() => const UserHospitalsPublic());
                        },
                      ),

                      SizedBox(height: 20),
                      // Repeat for other modules
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavBar(
        initialIndex: 2,
      ),
    );
  }

  Widget buildModuleContainer({
    required IconData icon,
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: primary, // Background color of the container
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                image,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color:
                Colors.black.withOpacity(0.5), // Semi-transparent overlay
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    color: wColor,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      color: wColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
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
}
