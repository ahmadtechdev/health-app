import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../colors.dart';
import '../admin/add_diet_screen.dart';
import 'diet_plan_detail_screen.dart';

class FitnessInfoUser extends StatefulWidget {
  const FitnessInfoUser({super.key});

  @override
  State<FitnessInfoUser> createState() => _FitnessInfoUserState();
}

class _FitnessInfoUserState extends State<FitnessInfoUser> {
  final dietTitle = Get.arguments['title'].toString();
  final description = Get.arguments['description']?.toString() ?? '';
  final _auth = FirebaseAuth.instance;

  bool get isAdmin =>
      _auth.currentUser?.email?.toLowerCase().contains('admin') ?? false;

  Future<void> _deletePlan(String docId) async {
    await FirebaseFirestore.instance.collection("diet").doc(docId).delete();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: Text(
          '$dietTitle Plan',
          style: const TextStyle(
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
              onPressed: () => Get.to(
                () => const AddDietScreen(),
                arguments: {'title': dietTitle},
              ),
              backgroundColor: TColors.primary,
              foregroundColor: TColors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Plan'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            _buildHeroCard(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("diet")
                    .where("title", isEqualTo: dietTitle)
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(TColors.primary),
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
                      icon: Icons.event_note,
                      title: 'No diet plans yet',
                      subtitle: isAdmin
                          ? 'Add a plan for this category using the + button.'
                          : 'Please check back later.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final planTitle = data['planTitle'] as String? ?? 'Plan';
                      final plan = data['plan'] as String? ?? '';
                      final createdAt = _formatDate(data['createdAT']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: TColors.background3),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            planTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: TColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Tap to read full plan',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: TColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                createdAt,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: TColors.placeholder,
                                ),
                              ),
                            ],
                          ),
                          trailing: isAdmin
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _deletePlan(doc.id);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
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
                              () => const DietPlanDetailScreen(),
                              arguments: {'title': planTitle, 'plan': plan},
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [TColors.primary, TColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.accent.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this plan',
            style: TextStyle(
              color: TColors.white,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dietTitle,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
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