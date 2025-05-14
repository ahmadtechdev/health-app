
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';
import '../../treatment/admin_treatment_list.dart';
import '../../treatment/home_treatment.dart';
import '../admin_doctor_category.dart';
import '../admin_home_screen.dart';
import 'admin_hospitals_private.dart';
import 'admin_hospitals_public.dart';

class AdminHospitalType extends StatefulWidget {
  const AdminHospitalType({super.key});

  @override
  State<AdminHospitalType> createState() => _AdminHospitalTypeState();
}

class _AdminHospitalTypeState extends State<AdminHospitalType> {
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
                        image: 'assets/images/hospital.jpg',
                        title: 'Private',
                        onTap: () {
                          Get.to(() => AdminHospitalsPrivate());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.public,
                        image: 'assets/images/doctors.jpg',
                        title: 'Public',
                        onTap: () {
                          Get.to(() => const AdminHospitalsPublic());
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
          currentIndex: 2,
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
