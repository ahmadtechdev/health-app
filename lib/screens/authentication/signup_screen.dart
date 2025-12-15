// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../services/signUpServices.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final userNameController = TextEditingController();
  final userPhoneController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool hidePassword = true;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    userNameController.dispose();
    userPhoneController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Show error message using GetX snackbar
  void _showMessage(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? TColors.error.withOpacity(0.9) : TColors.success.withOpacity(0.9),
      colorText: TColors.white,
      margin: EdgeInsets.all(15),
      borderRadius: 10,
      duration: Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: TColors.white,
      ),
    );
  }

  // Custom input field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: TColors.textPrimary, fontSize: 16.0),
        keyboardType: keyboardType,
        obscureText: isPassword ? hidePassword : false,
        decoration: InputDecoration(
          filled: true,
          fillColor: TColors.white,
          hintText: label,
          hintStyle: TextStyle(color: TColors.placeholder),
          errorStyle: TextStyle(color: TColors.error),
          prefixIcon: Icon(icon, color: TColors.accent),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              hidePassword ? Icons.visibility_off : Icons.visibility,
              color: TColors.accent,
            ),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: TColors.background3, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: TColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: TColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: TColors.error, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  // Signup button with loading state
  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColors.primary, TColors.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              isLoading = true;
            });

            try {
              var userName = userNameController.text.trim();
              var userPhone = userPhoneController.text.trim();
              var userEmail = userEmailController.text.trim();
              var userPassword = userPasswordController.text.trim();

              await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                  email: userEmail, password: userPassword)
                  .then((value) {
                _showMessage("Success", "Account created successfully", false);
                signUpUser(
                  userName,
                  userPhone,
                  userEmail,
                  userPassword,
                );
              });
            } on FirebaseAuthException catch (e) {
              String errorMessage = "An error occurred during sign up";
              
              switch (e.code) {
                case 'email-already-in-use':
                  errorMessage = "The email address is already in use by another account";
                  break;
                case 'invalid-email':
                  errorMessage = "The email address is invalid";
                  break;
                case 'weak-password':
                  errorMessage = "The password is too weak. Please use a stronger password";
                  break;
                case 'operation-not-allowed':
                  errorMessage = "Email/password accounts are not enabled";
                  break;
                case 'too-many-requests':
                  errorMessage = "Too many requests. Please try again later";
                  break;
                default:
                  errorMessage = e.message ?? "An error occurred during sign up";
              }
              
              _showMessage("Error", errorMessage, true);
            } catch (e) {
              _showMessage("Error", "An unexpected error occurred. Please try again", true);
            } finally {
              setState(() {
                isLoading = false;
              });
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: TColors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, color: TColors.white),
            SizedBox(width: 10),
            Text(
              "Create Account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TColors.background3,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: TColors.accent,
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Header
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Please fill in the details to sign up",
                    style: TextStyle(
                      fontSize: 16,
                      color: TColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Animation
                  Hero(
                    tag: "auth_animation",
                    child: Center(
                      child: Container(
                        height: 200,
                        child: Lottie.asset(
                          "assets/Animation - Authentication.json",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: userNameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your name";
                            } else if (value.length < 3) {
                              return 'Name must be more than 2 characters';
                            }
                            return null;
                          },
                        ),

                        _buildInputField(
                          controller: userPhoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                            RegExp regExp = RegExp(pattern);
                            if (value!.isEmpty) {
                              return "Please enter your phone number";
                            } else if (value.length < 10) {
                              return 'Enter minimum 10 digit mobile number';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Please enter valid mobile number';
                            }
                            return null;
                          },
                        ),

                        _buildInputField(
                          controller: userEmailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter your email";
                            } else if (!value.contains('@') || !value.contains('.')) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),

                        _buildInputField(
                          controller: userPasswordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a password";
                            } else if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Sign up button
                  _buildSignUpButton(),

                  // Sign in link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                                  () => SignInScreen(),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: TColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}