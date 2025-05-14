import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import '../widgets/app_bar.dart';

class PharmacyInfo extends StatefulWidget {
  const PharmacyInfo({super.key});

  @override
  State<PharmacyInfo> createState() => _PharmacyInfoState();
}

class _PharmacyInfoState extends State<PharmacyInfo> {

  int ratingInt = int.tryParse(Get.arguments['rating'].toString()) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Pharmacy Information",
              backButton: false,
              signOutIcon: false,
              backgroundColor: primary,
              foregroundColor:
              wColor, // Example of using a different background color
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.9),
                      primary.withOpacity(0.2),
                      primary.withOpacity(0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              alignment: Alignment.center,
              height: 170.0,
              child: Lottie.asset(
                "assets/Animation - pharmacy.json",
                width: 250,
                height: 100,
                fit: BoxFit.cover, // Adjust the fit property as needed
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "${Get.arguments['name'].toString()}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:Row(
                      children: [
                        for (int i = 1; i <= ratingInt; i++)
                          Icon(
                            Icons.star,
                            color: Colors.amber, // Adjust color as desired
                            size: 18.0,
                          ),
                        if (ratingInt < 5)
                          for (int i = ratingInt + 1; i <= 5; i++)
                            Icon(
                              Icons.star_border,
                              color: Colors.amber, // Adjust color as desired
                              size: 18.0,
                            ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [primary.withOpacity(0.4), primary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "${Get.arguments['location'].toString()}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "${Get.arguments['contact'].toString()}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),

          ],
        ),
      ),
    );
  }
}
