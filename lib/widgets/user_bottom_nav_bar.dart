import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import '../screens/treatment/home_treatment.dart';
import '../screens/user/user_home_screen.dart';
import '../screens/user/userHospital/user_hospital_type.dart';
import '../screens/user/user_doctor_category.dart';

class UserBottomNavBar extends StatefulWidget {
  final int initialIndex;

  const UserBottomNavBar({
    super.key,
    required this.initialIndex,
  });

  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();
}

class _UserBottomNavBarState extends State<UserBottomNavBar> {
  late int _selectedIndex;

  final List<Map<String, dynamic>> _items = [
    {'icon': Icons.home_outlined, 'label': 'Home'},
    {'icon': MdiIcons.pill, 'label': 'Treatment'},
    {'icon': MdiIcons.hospitalBuilding, 'label': 'Hospitals'},
    {'icon': MdiIcons.doctor, 'label': 'Doctors'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant UserBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offAll(() => const UserHome());
        break;
      case 1:
        Get.to(() => const ExampleAlarmHomeScreen());
        break;
      case 2:
        Get.to(() => const UserHospitalType());
        break;
      case 3:
        Get.to(() => const UserDoctorCategory());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        children: List.generate(_items.length, (index) {
          final isSelected = _selectedIndex == index;

          return InkWell(
            onTap: () => _onNavItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isSelected ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? TColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[index]['icon'] as IconData,
                    color: isSelected ? TColors.primary : TColors.grey,
                    size: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Text(
                      _items[index]['label'] as String,
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
}

