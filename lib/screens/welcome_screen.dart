import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../colors.dart';
import 'authentication/signin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For responsive sizing
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColors.background,
              TColors.background2,
              TColors.background3,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 1200.ms)
                      .slide(begin: Offset(0, 0.2), end: Offset.zero, duration: 1500.ms)

              ),
              Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: TColors.accent.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 1200.ms)
                      .slide(begin: Offset(0, 0.2), end: Offset.zero, duration: 1500.ms)

              ),

              // Main content column
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    // Animation centered and contained
                    Container(
                      height: size.height * 0.35,
                      child: Lottie.asset(
                        'assets/Animation - health.json',
                        fit: BoxFit.contain,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 1000.ms)
                        .slide(duration: 800.ms, begin: Offset(0, 0.1)),

                    SizedBox(height: size.height * 0.04),

                    // Title with shadow
                    Text(
                      "Gro Health",
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: TColors.accent.withOpacity(0.5),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 1000.ms)
                        .slide(delay: 300.ms, duration: 800.ms, begin:  Offset(0, 0.2)),

                    SizedBox(height: 16),

                    // Subtitle
                    Text(
                      "Grow Stronger, Live Healthier.",
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 1000.ms)
                        .slide(delay: 500.ms, duration: 800.ms, begin: Offset(0, 0.2)),

                    Spacer(),

                    // Button with modern design and shadow
                    Container(
                      width: size.width * 0.8,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [TColors.primary, TColors.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.accent.withOpacity(0.5),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            Get.to(()=>SignInScreen(), transition: Transition.fade);
                            // Navigator.push(
                            //   context,
                            //   PageRouteBuilder(
                            //     pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
                            //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            //       return FadeTransition(
                            //         opacity: animation,
                            //         child: child,
                            //       );
                            //     },
                            //     transitionDuration: Duration(milliseconds: 500),
                            //   ),
                            // );
                          },
                          splashColor: TColors.background3,
                          child: Center(
                            child: Text(
                              "LET'S GO",
                              style: TextStyle(
                                color: TColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 1000.ms)
                        .slideY(delay: 700.ms, duration: 800.ms, begin: 0.3),

                    SizedBox(height: 40),

                    // Heart icon with animation
                    Image.asset(
                      'assets/images/lined heart.png',
                      color: TColors.accent,
                      height: 32,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(delay: 900.ms, duration: 800.ms)
                        .then(delay: 500.ms)
                        .scale(
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                      begin: Offset(1, 1),
                      end: Offset(1.1, 1.1),
                    )
                        .then(delay: 200.ms)
                        .scale(
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                      begin: Offset(1, 1),
                      end: Offset(0.9, 0.9),
                    ),

                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}