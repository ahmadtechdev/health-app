
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../screens/authentication/signin_screen.dart';

class CustomHomeAppBar extends StatelessWidget {
  final String title;
  final bool backButton;
  final IconData backButtonIcon;
  final bool signOutIcon;
  final Color backgroundColor;

  CustomHomeAppBar({
    required this.title,
    this.backButton = false,
    this.backButtonIcon = Icons.arrow_back,
    this.signOutIcon = false,
    this.backgroundColor = Colors.blue, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusted to space between
        children: <Widget>[
          if (backButton)
            IconButton(
              icon: Icon(backButtonIcon,color: wColor,),
              onPressed: () {
                // Handle back button press here
                Navigator.of(context).pop();
              },
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left:50), // Adjust padding
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: wColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (signOutIcon)
            IconButton(
              icon: Icon(Icons.logout, color: wColor,),
              onPressed: () {
                // Handle sign-out icon press here
                FirebaseAuth.instance.signOut();
                Get.off(() => SignInScreen());
              },
            ),
        ],
      ),
    );
  }
}

