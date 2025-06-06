// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../colors.dart';


import '../../widgets/app_bar_for_home.dart';

import '../chatBot.dart';
import '../treatment/home_treatment.dart';
import 'adminHospital/admin_hospital_type.dart';
import 'admin_doctor_category.dart';
import 'admin_pharmacy.dart';
import 'diet_fitness_screen.dart';
import 'search_scan.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: wColor),
          child: Column(
            children: [
              CustomHomeAppBar(
                title: "Admin Home",
                backButton: false,
                signOutIcon: true,
                backgroundColor:
                    primary, // Example of using a different background color
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildModuleContainer(
                        icon: Icons.local_hotel,
                        image: 'assets/images/hospital.jpg',
                        title: 'Hospitals',
                        onTap: () {
                          Get.to(()=> AdminHospitalType());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.person,
                        image: 'assets/images/doctors.jpg',
                        title: 'Doctors',
                        onTap: () {
                          Get.to(()=> const AdminDoctorCategory());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.local_pharmacy,
                        image: 'assets/images/pharmacy.jpg',
                        title: 'Pharmacy',
                        onTap: () {
                          Get.to(()=> const AdminPharmacy());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: MdiIcons.medication,
                        image: 'assets/images/botimage.jpg',
                        title: 'MediGuide',
                        onTap: () {
                          Get.to(()=> const ChatScreen());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.local_hospital,
                        image: 'assets/images/doctor3.jpg',
                        title: 'Treatment',
                        onTap: () {
                          Get.to(()=> const ExampleAlarmHomeScreen());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.fitness_center,
                        image: 'assets/images/diet.jpg',
                        title: 'Diet & Fitness Plan',
                        onTap: () {
                          Get.to(()=> FitnessPlan());
                        },
                      ),
                      SizedBox(height: 20),
                      buildModuleContainer(
                        icon: Icons.camera_alt,
                        image: 'assets/images/search&scan.jpg',
                        title: 'Search by Scan',
                        onTap: () {
                          Get.to(()=> SearchScan());
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
          currentIndex: 0,
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
                    size: 60,
                  ),
                  SizedBox(height: 10),
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
