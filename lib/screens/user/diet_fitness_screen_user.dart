import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../colors.dart';
import '../admin/add_fitness_screen.dart';
import 'fitness_info_screen_user.dart';

class FitnessPlanUser extends StatefulWidget {
  const FitnessPlanUser({super.key});

  @override
  State<FitnessPlanUser> createState() => _FitnessPlanUserState();
}

class _FitnessPlanUserState extends State<FitnessPlanUser> {
  final _auth = FirebaseAuth.instance;

  bool get isAdmin =>
      _auth.currentUser?.email?.toLowerCase().contains('admin') ?? false;

  Future<void> _deleteCategory(String docId) async {
    await FirebaseFirestore.instance.collection("fitness").doc(docId).delete();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: const Text(
          'Diet & Fitness',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Get.to(() => const AddFitnessScreen());
              },
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("fitness")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildMessage(
                icon: Icons.error_outline,
                title: 'Failed to load plans',
                subtitle: 'Please try again later.',
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                ),
              );
            }
            final docs = List<QueryDocumentSnapshot>.from(
                snapshot.data?.docs ?? <QueryDocumentSnapshot>[]);
            docs.sort((a, b) {
              final aDate =
                  (a['createdAT'] as Timestamp?)?.toDate() ?? DateTime(0);
              final bDate =
                  (b['createdAT'] as Timestamp?)?.toDate() ?? DateTime(0);
              return bDate.compareTo(aDate);
            });
            if (docs.isEmpty) {
              return _buildMessage(
                icon: Icons.fitness_center,
                title: 'No plans yet',
                subtitle: 'Add your first diet & fitness plan to get started.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] as String? ?? 'Plan';
                final desc = data['desc'] as String? ?? '';
                final createdAt = _formatDate(data['createdAT']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TColors.background3),
                    boxShadow: [
                      BoxShadow(
                        color: TColors.greyLight.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: TColors.primary,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: TColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          createdAt,
                          style: const TextStyle(
                            color: TColors.placeholder,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: isAdmin
                        ? PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await _deleteCategory(doc.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: TColors.placeholder,
                          ),
                    onTap: () {
                      Get.to(
                        () => const FitnessInfoUser(),
                        arguments: {
                          'title': title,
                          'description': desc,
                          'id': doc.id,
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: TColors.accent),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    DateTime? date;
    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }
}