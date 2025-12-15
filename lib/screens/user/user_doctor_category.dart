
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/user_bottom_nav_bar.dart';
import 'userHospital/user_hospital_type.dart';
import 'user_doctor_list.dart';
import 'user_home_screen.dart';

class UserDoctorCategory extends StatefulWidget {
  const UserDoctorCategory({super.key});

  @override
  State<UserDoctorCategory> createState() => _UserDoctorCategoryState();
}

class _UserDoctorCategoryState extends State<UserDoctorCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: wColor),
          child: Column(
            children: [
              CustomAppBar(
                  title: "Doctor Specialities",
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
                        image: 'assets/images/dental-doctor.jpg',
                        title: 'Dental',
                        onTap: () {
                          Get.to(() => UserDoctor(), arguments: {
                            'category': "Dental",
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/heart-doctor.jpg',
                        title: 'Heart',
                        onTap: () {
                          Get.to(() => const UserDoctor(), arguments: {
                            'category': "Heart",
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/eye-doctor.jpg',
                        title: 'Eye',
                        onTap: () {
                          Get.to(() => const UserDoctor(), arguments: {
                            'category': "Eye",
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/brain-doctor.jpg',
                        title: 'Brain',
                        onTap: () {
                          Get.to(() => const UserDoctor(), arguments: {
                            'category': "Brain",
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/ear-doctor.jpg',
                        title: 'Ear',
                        onTap: () {
                          Get.to(() => const UserDoctor(), arguments: {
                            'category': "Ear",
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/doctor3.jpg',
                        title: 'General',
                        onTap: () {
                          Get.to(() => const UserDoctor(), arguments: {
                            'category': "General",
                          });
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
        initialIndex: 3,
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
        height: 150,
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
                    size: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    title,
                    style: TextStyle(
                      color: wColor,
                      fontSize: 30,
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
