
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';
import '../../treatment/home_treatment.dart';
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
      Get.to(() => UserHome());
    } else if (index == 1) {
      Get.to(() => ExampleAlarmHomeScreen());
    } else if (index == 2) {
      Get.to(() => UserHospitalType());
    } else if (index == 3) {
      Get.to(() => UserDoctorCategory());
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
