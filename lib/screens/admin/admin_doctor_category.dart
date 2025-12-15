import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';

import '../treatment/home_treatment.dart';
import 'adminHospital/admin_hospital_type.dart';
import 'admin_doctor_list.dart';
import 'admin_home_screen.dart';

class AdminDoctorCategory extends StatefulWidget {
  const AdminDoctorCategory({super.key});

  @override
  State<AdminDoctorCategory> createState() => _AdminDoctorCategoryState();
}

class _AdminDoctorCategoryState extends State<AdminDoctorCategory> {
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
                    Get.off(() => AdminHome());
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
                          Get.to(() => AdminDoctor(), arguments: {
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
                          Get.to(() => const AdminDoctor(), arguments: {
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
                          Get.to(() => const AdminDoctor(), arguments: {
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
                          Get.to(() => const AdminDoctor(), arguments: {
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
                          Get.to(() => const AdminDoctor(), arguments: {
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
                          Get.to(() => const AdminDoctor(), arguments: {
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: primary, width: 2.0))),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: wColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.pill),
              label: 'Treatment',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                MdiIcons.hospital,
              ),
              label: 'Hospitals',
            ),

            BottomNavigationBarItem(
              icon: Icon(MdiIcons.doctor),
              label: 'Doctors',
            ),
          ],
          currentIndex: 3,
          selectedItemColor: primary,
          unselectedItemColor: y1Color,
          onTap: onTabTapped,
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    if (index == 0) {
      Get.to(() => AdminHome());
    } else if (index == 1) {
      Get.to(() => ExampleAlarmHomeScreen());
    } else if (index == 2) {
      Get.to(() => AdminHospitalType());
    } else if (index == 3) {
      Get.to(() => AdminDoctorCategory());
    }
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
