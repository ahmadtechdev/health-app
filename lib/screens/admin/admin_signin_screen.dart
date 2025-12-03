

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import '../authentication/signin_screen.dart';
import 'admin_home_screen.dart';

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({super.key});

  @override
  State<AdminSignInScreen> createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Admin Sign In",
              backButton: true,
              signOutIcon: false,
              backgroundColor:
                  primary, // Example of using a different background color
            ),
            Container(
              alignment: Alignment.center,
              height: 300.0,
              child: Lottie.asset("assets/Animation - Authentication.json"),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: loginEmailController,
                style: const TextStyle(color: primary, fontSize: 17.0),
                decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.email, color: primary.withOpacity(0.6)),
                    // suffixIcon: Icon(Icons.email),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: primary,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: primary.withOpacity(0.6),
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: primary.withOpacity(0.8))),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return "Please enter a valid Email address";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: loginPasswordController,
                obscureText: true,
                style: const TextStyle(color: primary, fontSize: 17.0),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: primary.withOpacity(0.6),
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: primary.withOpacity(0.8), fontSize: 17.0),
                  prefixIcon: Icon(
                    Icons.password,
                    color: primary.withOpacity(0.6),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a password ";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: RoundedButton(
                title: "Sign in",
                icon: Icons.login,
                onTap: () async {
                  var loginEmail = loginEmailController.text.trim();
                  var loginPassword = loginPasswordController.text.trim();
                  try {
                    final User? firebaseUser = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: loginEmail, password: loginPassword))
                        .user;

                    if (firebaseUser != null) {
                      Get.to(() => const AdminHome());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Check email & password"),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          margin: EdgeInsets.only(
                              bottom: 12, right: 20, left: 20),
                        ),
                      );
                      print("CHeck Email & password");
                    }
                  } on FirebaseAuthException catch (e) {
                    String errorMessage = "Authentication failed";
                    switch (e.code) {
                      case 'user-not-found':
                        errorMessage = "No user found with this email";
                        break;
                      case 'wrong-password':
                        errorMessage = "Wrong password provided";
                        break;
                      case 'invalid-credential':
                        errorMessage = "Invalid email or password";
                        break;
                      case 'invalid-email':
                        errorMessage = "The email address is invalid";
                        break;
                      case 'user-disabled':
                        errorMessage = "This user account has been disabled";
                        break;
                      case 'too-many-requests':
                        errorMessage = "Too many failed attempts. Please try again later";
                        break;
                      case 'operation-not-allowed':
                        errorMessage = "Email/password sign-in is not enabled";
                        break;
                      default:
                        errorMessage = e.message ?? "Authentication failed. Please check your email and password";
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        margin: EdgeInsets.only(
                            bottom: 12, right: 20, left: 20),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("An unexpected error occurred. Please try again"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        margin: EdgeInsets.only(
                            bottom: 12, right: 20, left: 20),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const SignInScreen());
              },
              child: const Card(
                  color: primary,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("User SignIn",
                        style: TextStyle(
                            color: wColor, fontWeight: FontWeight.bold)),
                  )),
            ),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
