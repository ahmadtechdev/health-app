import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/authentication/signin_screen.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool backButton;
  final IconData backButtonIcon;
  final bool signOutIcon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onBackButtonPressed;


  CustomAppBar({
    required this.title,
    this.backButton = false,
    this.backButtonIcon = Icons.arrow_back,
    this.signOutIcon = false,
    this.backgroundColor = Colors.blue, // Default background color
    this.foregroundColor = Colors.white,
    this.onBackButtonPressed, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusted to space between
        children: <Widget>[
          if (backButton)
            IconButton(
              icon: Icon(backButtonIcon,color: foregroundColor,),
              onPressed: () {
                // Handle back button press here
                // Navigate to the specified route if provided, else pop the current route
                if (onBackButtonPressed != null) {
                  onBackButtonPressed!(); // Execute the provided callback
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right:48), // Adjust padding
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (signOutIcon)
            IconButton(
              icon: Icon(Icons.logout, color: foregroundColor,),
              onPressed: () {
                // Handle sign-out icon press here
                FirebaseAuth.instance.signOut();
                Get.off(() => const SignInScreen());
              },
            ),
        ],
      ),
    );
  }
}

// class Page extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           CustomAppBar(
//             title: "Custom App Bar",
//             backButton: true,
//             signOutIcon: true,
//             backgroundColor: Colors.red, // Example of using a different background color
//           ),
//           // Other body content goes here
//           Expanded(
//             child: Container(
//               color: Colors.grey[200],
//               child: Center(
//                 child: Text("Your content here"),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
