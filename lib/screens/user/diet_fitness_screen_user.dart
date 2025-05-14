import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../colors.dart';
import '../admin/add_fitness_screen.dart';
import 'fitness_info_screen_user.dart';
import 'user_home_screen.dart';

class FitnessPlanUser extends StatefulWidget {
  const FitnessPlanUser({super.key});

  @override
  State<FitnessPlanUser> createState() => _FitnessPlanUserState();
}

class _FitnessPlanUserState extends State<FitnessPlanUser> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(BuildContext context, String name) async {
    bool confirmDelete = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Plan",
            style: TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete \"$name\"? This action cannot be undone.",
            style: TextStyle(
              color: TColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                confirmDelete = false;
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                confirmDelete = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.error,
                foregroundColor: TColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmDelete;
  }

  // Method to delete plan from Firestore
  Future<void> _deletePlan(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("fitness")
          .doc(docId)
          .delete();

      // Show success snackbar
      Get.snackbar(
        "Success",
        "Plan deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete plan. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.error.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-30 * (1 - _animation.value), 0),
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12, top: 8),
                    decoration: BoxDecoration(
                      color: TColors.background.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.accent.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: TColors.textPrimary),
                      onPressed: () {
                        Get.off(UserHome());
                      },
                    ),
                  ),
                ),
              );
            }
        ),
        centerTitle: true,
        title: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - _animation.value)),
                child: Opacity(
                  opacity: _animation.value,
                  child: Text(
                    "Diet & Fitness",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                      fontSize: 24,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: TColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      ),
      backgroundColor: TColors.background,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _animation.value)),
                        child: Opacity(
                          opacity: _animation.value,
                          child: Text(
                            "Your wellness journey starts here",
                            style: TextStyle(
                              fontSize: 16,
                              color: TColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _animation.value)),
                        child: Opacity(
                          opacity: _animation.value,
                          child: Text(
                            "Swipe left or right to delete a plan",
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.textSecondary.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("fitness")
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return ErrorWidget(
                          "Something went wrong!",
                          animation: _animation,
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: LoadingIndicator(animation: _animation),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return EmptyDataWidget(animation: _animation);
                      }

                      if (snapshot.data != null) {
                        return AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var name = snapshot.data!.docs[index]['title'];
                              var time = snapshot.data!.docs[index]['createdAT'];
                              var desc = snapshot.data!.docs[index]['desc'];
                              var docId = snapshot.data!.docs[index].id;

                              // Get category type for icon selection (or use default)
                              var category = "general";
                              // var category = snapshot.data!.docs[index]['category'] ?? "general";
                              var iconData = _getCategoryIcon(category);

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 600),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Slidable(
                                      key: ValueKey(docId),
                                      // Slide actions on the left side
                                      startActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        dismissible: DismissiblePane(
                                          key: ValueKey('left_$docId'),
                                          onDismissed: () {},
                                          closeOnCancel: true,
                                          confirmDismiss: () async {
                                            bool confirm = await _showDeleteConfirmation(context, name);
                                            if (confirm) {
                                              await _deletePlan(docId);
                                            }
                                            return false; // Always return false to prevent actual dismissal
                                          },
                                        ),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) async {
                                              bool confirm = await _showDeleteConfirmation(context, name);
                                              if (confirm) {
                                                await _deletePlan(docId);
                                              }
                                            },
                                            backgroundColor: TColors.error,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                            borderRadius: const BorderRadius.horizontal(
                                              left: Radius.circular(16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Slide actions on the right side
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        dismissible: DismissiblePane(
                                          key: ValueKey('right_$docId'),
                                          onDismissed: () {},
                                          closeOnCancel: true,
                                          confirmDismiss: () async {
                                            bool confirm = await _showDeleteConfirmation(context, name);
                                            if (confirm) {
                                              await _deletePlan(docId);
                                            }
                                            return false; // Always return false to prevent actual dismissal
                                          },
                                        ),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) async {
                                              bool confirm = await _showDeleteConfirmation(context, name);
                                              if (confirm) {
                                                await _deletePlan(docId);
                                              }
                                            },
                                            backgroundColor: TColors.error,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                            borderRadius: const BorderRadius.horizontal(
                                              right: Radius.circular(16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: TColors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: TColors.accent.withOpacity(0.15),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
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
                                              onTap: () {
                                                Get.to(() => FitnessInfoUser(), arguments: {
                                                  "title": name,
                                                  "description": desc,
                                                  'id': docId,
                                                  'time': time,
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        color: TColors.background3,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Icon(
                                                        iconData,
                                                        color: TColors.accent,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            name,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: TColors.textPrimary,
                                                              fontSize: 18,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 6),
                                                          Text(
                                                            desc,
                                                            style: TextStyle(
                                                              color: TColors.textSecondary,
                                                              fontSize: 14,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      color: TColors.accent,
                                                      size: 16,
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
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const AddFitnessScreen());
          },
          backgroundColor: TColors.accent,
          label: Row(
            children: [
              Icon(
                Icons.add,
                color: TColors.white,
              ),
              const SizedBox(width: 8),
              Text(
                "Add Plan",
                style: TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          elevation: 8,
        ),
      ),
    );
  }

  // Helper method to determine icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'diet':
        return Icons.restaurant_menu;
      case 'workout':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.directions_run;
      case 'meditation':
        return Icons.spa;
      default:
        return Icons.health_and_safety;
    }
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
          );
        }
    );
  }
}

class EmptyDataWidget extends StatelessWidget {
  final Animation<double> animation;

  const EmptyDataWidget({required this.animation, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: TColors.accent.withOpacity(0.5),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No fitness plans found",
                    style: TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Start by adding your first fitness plan",
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => const AddFitnessScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.accent,
                      foregroundColor: TColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "Add First Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                  "Loading your fitness plans...",
                  style: TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}