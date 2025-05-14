import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../colors.dart';
import '../admin/diet_info_screen.dart';
import 'diet_fitness_screen_user.dart';

class FitnessInfoUser extends StatefulWidget {
  const FitnessInfoUser({super.key});

  @override
  State<FitnessInfoUser> createState() => _FitnessInfoUserState();
}

class _FitnessInfoUserState extends State<FitnessInfoUser> with SingleTickerProviderStateMixin {
  String dietTitle = Get.arguments['title'].toString();
  String description = Get.arguments['description'].toString();
  late AnimationController _controller;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  bool _showHeaderShadow = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    );

    _controller.forward();

    _scrollController.addListener(() {
      setState(() {
        _showHeaderShadow = _scrollController.offset > 10;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TColors.background,
              TColors.background2,
              TColors.background3.withOpacity(0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _animation.value,
                            child: Transform.scale(
                              scale: 0.8 + (0.2 * _animation.value),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      TColors.accent.withOpacity(0.8),
                                      TColors.primary.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TColors.accent.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -30,
                                      bottom: -20,
                                      child: Icon(
                                        _getCategoryIcon(dietTitle),
                                        size: 150,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "$dietTitle Plan",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            description,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                  leading: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-30 * (1 - _animation.value), 0),
                          child: Opacity(
                            opacity: _animation.value,
                            child: Container(
                              margin: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                color: TColors.background.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColors.accent.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios_new_rounded, color: TColors.textPrimary),
                                onPressed: () {
                                  Get.off(FitnessPlanUser());
                                },
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - _animation.value)),
                          child: Opacity(
                            opacity: _animation.value,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Stats cards
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.timer,
                                            title: "Duration",
                                            value: "4 Weeks",
                                            color: TColors.success,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.star,
                                            title: "Difficulty",
                                            value: "Intermediate",
                                            color: TColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Program title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      "Program Details",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: TColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),

                // Diet Plans List
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("diet")
                      .where("title", isEqualTo: dietTitle)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: ErrorWidget(
                          "Something went wrong!",
                          animation: _animation,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: LoadingIndicator(animation: _animation),
                        ),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyDataWidget(
                          animation: _animation,
                          title: dietTitle,
                        ),
                      );
                    }

                    if (snapshot.data != null) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        sliver: SliverAnimationBuilder(
                          delay: 600,
                          child: SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                var name = snapshot.data!.docs[index]['planTitle'];
                                var time = snapshot.data!.docs[index]['createdAT'];
                                var plan = snapshot.data!.docs[index]['plan'];
                                var docId = snapshot.data!.docs[index].id;

                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => DietInfoScreen(), arguments: {
                                      "title": name,
                                      "plan": plan,
                                      'id': docId,
                                      'time': time,
                                    });
                                  },
                                  child: _buildPlanCard(
                                    title: name,
                                    index: index,
                                  ),
                                );
                              },
                              childCount: snapshot.data!.docs.length,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),

            // Floating Action Button
            Positioned(
              bottom: 24,
              right: 24,
              child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _showFavoriteDialog(context);
                        },
                        backgroundColor: TColors.accent,
                        label: Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: TColors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Save Plan",
                              style: TextStyle(
                                color: TColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        elevation: 8,
                      ),
                    );
                  }
              ),
            ),

            // Header shadow when scrolling
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: 0,
              right: 0,
              height: _showHeaderShadow ? 110 : 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TColors.background,
                      TColors.background.withOpacity(_showHeaderShadow ? 0.8 : 0),
                      TColors.background.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build stat cards
  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.accent.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build plan cards
  Widget _buildPlanCard({required String title, required int index}) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: 100 * index),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TColors.accent.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: TColors.accent.withOpacity(0.1),
                  highlightColor: TColors.accent.withOpacity(0.05),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: TColors.background3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getPlanIcon(index),
                            color: TColors.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: TColors.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: TColors.accent.withOpacity(0.6),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Tap to view details",
                                    style: TextStyle(
                                      color: TColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: TColors.background2,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: TColors.accent,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to determine icon based on plan index
  IconData _getPlanIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.restaurant_menu;
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.local_dining;
      case 3:
        return Icons.breakfast_dining;
      default:
        return Icons.restaurant;
    }
  }

  // Helper method to determine icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'diet':
      case 'nutrition':
        return Icons.restaurant_menu;
      case 'workout':
      case 'exercise':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
      case 'running':
        return Icons.directions_run;
      case 'meditation':
      case 'mindfulness':
        return Icons.spa;
      case 'weight loss':
        return Icons.monitor_weight;
      default:
        return Icons.health_and_safety;
    }
  }

  // Show dialog when "Save Plan" button is pressed
  void _showFavoriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: TColors.background,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: TColors.accent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Plan Saved!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "This plan has been added to your favorites and will be accessible from your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: TColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.accent,
                    foregroundColor: TColors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Great!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
        ).fadeIn();
      },
    );
  }
}

// Custom SliverAnimationBuilder
class SliverAnimationBuilder extends StatelessWidget {
  final Widget child;
  final int delay;

  const SliverAnimationBuilder({
    required this.child,
    this.delay = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
      duration: 600.ms,
      delay: delay.ms,
      curve: Curves.easeOut,
    )
        .moveY(
      begin: 30,
      duration: 600.ms,
      delay: delay.ms,
      curve: Curves.easeOutQuint,
    );
  }
}

// Custom widgets for different states

class ErrorWidget extends StatelessWidget {
  final String message;
  final Animation<double> animation;

  const ErrorWidget(this.message, {required this.animation, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: TColors.error,
                      size: 70,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}

class EmptyDataWidget extends StatelessWidget {
  final Animation<double> animation;
  final String title;

  const EmptyDataWidget({required this.animation, required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: TColors.accent.withOpacity(0.5),
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No diet plans found for $title",
                      style: TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Check back later for updates to this fitness program",
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final Animation<double> animation;

  const LoadingIndicator({required this.animation, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(TColors.accent),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Loading diet plans...",
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}