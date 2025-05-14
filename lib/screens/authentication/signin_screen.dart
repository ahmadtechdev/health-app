// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../button.dart';
import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import '../admin/admin_signin_screen.dart';
import '../doctor/doctor_sigin.dart';
import '../forgot_password_screen.dart';
import '../user/user_home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Sign In",
              backButton: true,
              signOutIcon: false,
              backgroundColor:
                  primary, // Example of using a different background color
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 300.0,
                      child: Lottie.asset(
                          "assets/Animation - Authentication.json"),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: loginEmailController,
                              style: TextStyle(color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email,
                                      color: primary.withOpacity(0.6)),
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
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return "Please enter a valid Email address";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: loginPasswordController,
                              obscureText: true,
                              style: TextStyle(color: primary, fontSize: 17.0),
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
                                labelStyle: TextStyle(
                                    color: primary.withOpacity(0.8),
                                    fontSize: 17.0),
                                prefixIcon: Icon(
                                  Icons.password,
                                  color: primary.withOpacity(0.6),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 6) {
                                  return "Please enter a 6 digit password ";
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                          ],
                        )),
                    RoundedButton(
                      title: "Sign in",
                      icon: Icons.login,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          var loginEmail = loginEmailController.text.trim();
                          var loginPassword =
                              loginPasswordController.text.trim();
                          try {
                            final User? firebaseUser = (await FirebaseAuth
                                    .instance
                                    .signInWithEmailAndPassword(
                                        email: loginEmail,
                                        password: loginPassword))
                                .user;

                            if (firebaseUser != null) {
                              Get.to(() => UserHome());
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
                              print("Check Email & password !!!");
                            }
                          } on FirebaseAuthException catch (e) {
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
                            print("Error: $e");
                          }
                        }
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Get.to(() => ForgotPasswordScreen());
                    //   },
                    //   child: Container(
                    //     child: Card(
                    //         child: Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: Text("Forgot Password"),
                    //     )),
                    //   ),
                    // ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account "),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SignUpScreen());
                          },
                          child: Card(
                              color: primary,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Expanded(
                                  child: Text("SignUp",
                                      style: TextStyle(
                                          color: wColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => DoctorSignIn());
                      },
                      child: Container(
                        child: Card(
                            color: primary,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Doctor SignIn",
                                style: TextStyle(
                                    color: wColor, fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onDoubleTap: () {
                        Get.to(() => AdminSignInScreen());
                      },
                      child: Container(
                        child: Card(
                            color: primary,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Admin SignIn",
                                style: TextStyle(
                                    color: wColor, fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
