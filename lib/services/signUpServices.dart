import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../screens/authentication/signin_screen.dart';

signUpUser(String userName, String userPhone, String userEmail,
    String userPassword) async {
  User? userid = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance.collection("users").doc(userid!.uid).set({
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'createdAt': DateTime.now(),
      'userId': userid!.uid,
    }).then((value) => {
          FirebaseAuth.instance.signOut(),
          Get.to(() => SignInScreen()),
        });
  } on FirebaseException catch (e) {
    Get.snackbar(
      'Error',
      _getFirestoreErrorMessage(e),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.error.withOpacity(0.9),
      colorText: TColors.white,
      margin:   EdgeInsets.all(15),
      borderRadius: 10,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: TColors.white),
    );
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to create user profile. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: TColors.error.withOpacity(0.9),
      colorText: TColors.white,
      margin: EdgeInsets.all(15),
      borderRadius: 10,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: TColors.white),
    );
  }
}

String _getFirestoreErrorMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'You do not have permission to perform this operation';
    case 'unavailable':
      return 'The service is currently unavailable. Please try again later';
    case 'deadline-exceeded':
      return 'The operation took too long. Please try again';
    case 'resource-exhausted':
      return 'Too many requests. Please try again later';
    default:
      return e.message ?? 'Failed to save user data. Please try again';
  }
}
