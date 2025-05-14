import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';

class DietInfoScreen extends StatefulWidget {
  const DietInfoScreen({super.key});

  @override
  State<DietInfoScreen> createState() => _DietInfoScreenState();
}

class _DietInfoScreenState extends State<DietInfoScreen> {
  String dietTitle = Get.arguments['title'].toString();
  String dietPlan = Get.arguments['plan'].toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Doctor Information",
              backButton: true,
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
                "assets/Animation - fitness.json",
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
                      "${dietTitle}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _formatText(dietPlan),
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

  Widget _formatText(String text) {
    List<String> lines = text.split('\n');
    List<Widget> formattedWidgets = [];

    for (String line in lines) {
      if (line.startsWith('#')) {
        // Treat as heading
        formattedWidgets.add(
          Text(
            line.substring(1), // Remove the '#' from the text
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      } else if (line.startsWith('-')) {
        // Treat as bullet point
        formattedWidgets.add(
          Text(
            line.substring(1), // Remove the '-' from the text
            style: TextStyle(fontSize: 16),
          ),
        );
      } else {
        // Treat as regular text
        formattedWidgets.add(
          Text(
            line,
            style: TextStyle(fontSize: 16),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formattedWidgets,
    );
  }
}
