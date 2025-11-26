import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';

class DietPlanDetailScreen extends StatelessWidget {
  const DietPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final title = args['title'] as String? ?? 'Diet Plan';
    final planArg = args['plan'] as String?;
    final planId = args['id'] as String?;

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.textPrimary,
          ),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _loadPlan(planArg, planId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildMessage(
              icon: Icons.error_outline,
              title: 'Failed to load plan',
              subtitle: 'Please try again later.',
            );
          }
          final plan = snapshot.data ?? '';
          if (plan.isEmpty) {
            return _buildMessage(
              icon: Icons.document_scanner_outlined,
              title: 'Plan details not available',
              subtitle: 'This plan has no content yet.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(title),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: TColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TColors.background3),
                  ),
                  child: _buildFormattedPlan(plan),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _loadPlan(String? planArg, String? planId) async {
    if (planArg != null && planArg.isNotEmpty) return planArg;
    if (planId == null) return '';

    final doc = await FirebaseFirestore.instance
        .collection("diet")
        .doc(planId)
        .get();
    final data = doc.data();
    return data?['plan'] as String? ?? '';
  }

  Widget _buildHeaderCard(String title) {
    return Container(
      width: double.infinity,
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
            color: TColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diet Overview',
            style: TextStyle(
              color: TColors.white,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Stay consistent with your nutrition goals. Follow the plan below for best results.',
            style: TextStyle(
              color: TColors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedPlan(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      if (line.startsWith('#')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(
              line.substring(1).trim(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16,
                    color: TColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: TColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line.trim(),
              style: const TextStyle(
                fontSize: 16,
                color: TColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
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
}