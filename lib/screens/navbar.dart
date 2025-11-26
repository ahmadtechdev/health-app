
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import 'admin/adminHospital/admin_hospital_type.dart';
import 'admin/admin_doctor_category.dart';
import 'admin/admin_home_screen.dart';
import 'admin/admin_pharmacy.dart';
import 'user/diet_fitness_screen_user.dart';
import 'chatBot.dart';
import 'treatment/home_treatment.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    String userEmail = "";

    if (user != null) {
      userEmail = user.email ?? "";
    }
    return Drawer(
      backgroundColor: wColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(
              "Doctors App",
              style: TextStyle(
                  fontSize: 18, color: wColor, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              "",
              style: const TextStyle(
                  fontSize: 16, color: wColor, fontWeight: FontWeight.bold),
            ),

            decoration: const BoxDecoration(
              color: primary,
            ),
          ),
          ListTile(
            leading: Icon(MdiIcons.home),
            title: const Text(
              'Home',
              style: TextStyle(
                  fontSize: 17, color: bColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const AdminHome());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.hospitalBuilding),
            title: const Text(
              'Hospitals',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const AdminHospitalType());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.doctor),
            title: const Text(
              'Doctor',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const AdminDoctorCategory());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.pill),
            title: const Text(
              'Pharmacy',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const AdminPharmacy());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.medication),
            title: const Text(
              'MediGuide',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const ChatScreen());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.alarmMultiple),
            title: const Text(
              'Treatment',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const ExampleAlarmHomeScreen());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.weightLifter),
            title: const Text(
              'Diet & Fitness Plan',
              style: TextStyle(
                  fontSize: 17, color: primary, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => const FitnessPlanUser());
            },
          ),

        ],
      ),
    );
  }
}
