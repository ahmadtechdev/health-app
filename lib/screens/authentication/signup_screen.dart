// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';


import '../../colors.dart';
import '../../services/signUpServices.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import 'signin_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final userNameController = TextEditingController();
  final userPhoneController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userNameController.dispose();
    userPhoneController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
  }

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Sign Up",
              backButton: true,
              signOutIcon: false,
              backgroundColor:
              primary, // Example of using a different background color
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 250.0,
                      child: Lottie.asset("assets/Animation - Authentication.json"),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: userNameController,
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
                                labelText: 'User Name',
                                labelStyle:
                                TextStyle(color: primary.withOpacity(0.8), fontSize: 17.0),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: primary.withOpacity(0.6),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter a User Name";
                                } else if (value.length < 3) {
                                  return 'Name must be more than 2 character';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: userPhoneController,
                              style: const TextStyle(color: primary, fontSize: 17.0),
                              keyboardType: TextInputType.number,
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
                                labelText: 'Phone',
                                labelStyle:
                                TextStyle(color: primary.withOpacity(0.8), fontSize: 17.0),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: primary.withOpacity(0.6),
                                ),
                              ),
                              validator: (value) {
                                String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                RegExp regExp = RegExp(pattern);
                                if (value!.length == 10) {
                                  return 'Enter minimum 10 digit mobile number';
                                } else if (!regExp.hasMatch(value)) {
                                  return 'Please enter valid mobile number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: userEmailController,
                              style: const TextStyle(color: primary, fontSize: 17.0),
                              keyboardType: TextInputType.emailAddress,
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
                                labelText: 'Email',
                                labelStyle:
                                TextStyle(color: primary.withOpacity(0.8), fontSize: 17.0),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: primary.withOpacity(0.6),
                                ),
                              ),
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
                              controller: userPasswordController,
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
                                if (value!.isEmpty || value.length < 6) {
                                  return "Please enter a 6 digit password";
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
                        title: "Sign Up",
                        icon: Icons.verified_user_sharp,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var userName = userNameController.text.trim();
                            var userPhone = userPhoneController.text.trim();
                            var userEmail = userEmailController.text.trim();
                            var userPassword = userPasswordController.text.trim();
        
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                email: userEmail, password: userPassword)
                                .then((value) => {
                              printInfo(info: "User Created"),
                              signUpUser(
                                userName,
                                userPhone,
                                userEmail,
                                userPassword,
                              )
                            });
                          }
        
        
                        }),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account "),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => SignInScreen());
                          },
                          child: Container(
                            child: Card(
                              color: primary,
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Expanded(
                                child: Text("SignIn",
                                    style: TextStyle(
                                        color: wColor, fontWeight: FontWeight.bold)),
                              ),
                            )),
                          ),
                        ),
                      ],
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
