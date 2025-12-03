// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../colors.dart';
import '../user/user_home_screen.dart';
import '../doctor/doctor_sigin.dart';
import '../admin/admin_signin_screen.dart';
import '../forgot_password_screen.dart';
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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
  }

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      margin: EdgeInsets.all(15),
      borderRadius: 10,
      snackPosition: SnackPosition.TOP,
      backgroundColor: TColors.success,
      colorText: TColors.textPrimary,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: TColors.textPrimary),
      boxShadows: [
        BoxShadow(
          color: TColors.accent.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      margin: EdgeInsets.all(15),
      borderRadius: 10,
      snackPosition: SnackPosition.TOP,
      backgroundColor: TColors.error,
      colorText: TColors.textPrimary,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error, color: TColors.textPrimary),
      boxShadows: [
        BoxShadow(
          color: TColors.accent.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3),
        )
      ],
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var loginEmail = loginEmailController.text.trim();
      var loginPassword = loginPasswordController.text.trim();

      try {
        final User? firebaseUser = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: loginEmail,
            password: loginPassword)
        ).user;

        setState(() {
          _isLoading = false;
        });

        if (firebaseUser != null) {
          _showSuccessMessage("Login successful");
          Future.delayed(Duration(milliseconds: 500), () {
            Get.to(
                  () => UserHome(),
              transition: Transition.fadeIn,
              duration: Duration(milliseconds: 500),
            );
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

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
            errorMessage = e.message ?? "Authentication failed. Please try again";
        }

        _showErrorMessage(errorMessage);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage("An unexpected error occurred. Please try again");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background elements
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .slide(begin: Offset(0, 0.2), end: Offset.zero, duration: 1500.ms)

            ),

            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: TColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(110),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 800.ms)
                  .slide(begin: Offset(0, 0.2), end: Offset.zero, duration: 1500.ms)

            ),

            // Main content
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // App Bar
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          // Back button with animation
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: TColors.accent),
                            onPressed: () => Get.back(),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0, duration: 500.ms),

                          Spacer(),

                          // Title with animation
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: TColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.2, end: 0, duration: 500.ms),

                          Spacer(),

                          // Empty space for symmetry
                          SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Animation
                    Container(
                      alignment: Alignment.center,
                      height: size.height * 0.25,
                      child: Lottie.asset(
                        "assets/Animation - Authentication.json",
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slide(begin: Offset(0, 0.2), end: Offset.zero, duration: 1500.ms),


                    SizedBox(height: 16),

                    // Authentication form with animations
                    Container(
                      decoration: BoxDecoration(
                        color: TColors.background2,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.accent.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            TextFormField(
                              controller: loginEmailController,
                              style: TextStyle(color: TColors.textPrimary, fontSize: 16),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                fillColor: TColors.background,
                                filled: true,
                                prefixIcon: Icon(Icons.email_outlined, color: TColors.accent),
                                hintText: 'Email Address',
                                hintStyle: TextStyle(color: TColors.placeholder),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: TColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email cannot be empty";
                                }
                                if (!GetUtils.isEmail(value)) {
                                  return "Please enter a valid email";
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 800.ms)
                                .slideX(begin: 0.05, end: 0, duration: 600.ms),

                            SizedBox(height: 20),

                            // Password Field with toggle visibility
                            TextFormField(
                              controller: loginPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(color: TColors.textPrimary, fontSize: 16),
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                fillColor: TColors.background,
                                filled: true,
                                prefixIcon: Icon(Icons.lock_outline, color: TColors.accent),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: TColors.accent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                hintText: 'Password',
                                hintStyle: TextStyle(color: TColors.placeholder),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(color: TColors.primary, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password cannot be empty";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 800.ms)
                                .slideX(begin: -0.05, end: 0, duration: 600.ms),

                            SizedBox(height: 6),

                            // // Forgot password option
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: TextButton(
                            //     onPressed: () {
                            //       // Get.to(
                            //       //       () => ForgotPasswordScreen(),
                            //       //   transition: Transition.rightToLeft,
                            //       //   duration: Duration(milliseconds: 300),
                            //       // );
                            //     },
                            //     child: Text(
                            //       "Forgot Password?",
                            //       style: TextStyle(
                            //         color: TColors.accent,
                            //         fontSize: 14,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //     style: TextButton.styleFrom(
                            //       minimumSize: Size.zero,
                            //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            //     ),
                            //   ),
                            // )
                            //     .animate()
                            //     .fadeIn(delay: 500.ms, duration: 800.ms),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 800.ms)
                        .slideY(begin: 0.05, end: 0, duration: 600.ms),

                    SizedBox(height: 24),

                    // Sign In Button with loading state
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [TColors.primary, TColors.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _isLoading ? null : _signIn,
                          splashColor: TColors.background3,
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(TColors.background),
                              ),
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: TColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.login_rounded, color: TColors.textPrimary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 800.ms)
                        .slideY(begin: 0.1, end: 0, duration: 600.ms),

                    SizedBox(height: 30),

                    // Sign Up option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(
                                  () => SignUpScreen(),
                              transition: Transition.rightToLeft,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: TColors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 800.ms),

                    SizedBox(height: 24),

                    // Doctor & Admin login options
                    Container(
                      decoration: BoxDecoration(
                        color: TColors.background2,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.accent.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            "",
                            // "Other Login Options",
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Doctor login button
                              // _buildLoginOptionButton(
                              //   title: "Doctor",
                              //   icon: Icons.medical_services_outlined,
                              //   onTap: () {
                              //     Get.to(
                              //           () => DoctorSignIn(),
                              //       transition: Transition.fadeIn,
                              //       duration: Duration(milliseconds: 300),
                              //     );
                              //   },
                              // ),
                              //
                              // // Admin login button (double tap)
                              // _buildLoginOptionButton(
                              //   title: "Admin",
                              //   icon: Icons.admin_panel_settings_outlined,
                              //   onTap: () {
                              //     Get.snackbar(
                              //       'Admin Access',
                              //       'Double tap to access admin panel',
                              //       margin: EdgeInsets.all(15),
                              //       borderRadius: 10,
                              //       snackPosition: SnackPosition.BOTTOM,
                              //       backgroundColor: TColors.background3,
                              //       colorText: TColors.textPrimary,
                              //     );
                              //   },
                              //   onDoubleTap: () {
                              //     Get.to(
                              //           () => AdminSignInScreen(),
                              //       transition: Transition.fadeIn,
                              //       duration: Duration(milliseconds: 300),
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 800.ms)
                        .slideY(begin: 0.05, end: 0, duration: 600.ms),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOptionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onDoubleTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [TColors.primary.withOpacity(0.8), TColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TColors.background, size: 18),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: TColors.background,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}