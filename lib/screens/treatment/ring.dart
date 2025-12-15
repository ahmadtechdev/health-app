import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';

class ExampleAlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const ExampleAlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docFuture = FirebaseFirestore.instance
        .collection("treatment")
        .doc(alarmSettings.id.toString())
        .get();

    return Scaffold(
      backgroundColor: TColors.background,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: docFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                ),
              );
            }

            final data = snapshot.data?.data();
            final name = data?['name'] as String? ?? 'Dose reminder';
            final amount = data?['dose'] as String? ?? '';
            final unit = data?['unit'] as String? ?? '';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'It’s time for your medication',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      color: TColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [TColors.primary, TColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 64,
                        color: TColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    TimeOfDay(
                      hour: alarmSettings.dateTime.hour,
                      minute: alarmSettings.dateTime.minute,
                    ).format(context),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    amount.isNotEmpty ? '$amount $unit' : '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: TColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final now = DateTime.now();
                            Alarm.set(
                              alarmSettings: alarmSettings.copyWith(
                                dateTime: DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  now.hour,
                                  now.minute,
                                ).add(const Duration(minutes: 10)),
                              ),
                            ).then((_) => Navigator.pop(context));
                          },
                          icon: const Icon(Icons.snooze_rounded),
                          label: const Text('Snooze 10 min'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TColors.textSecondary,
                            side: const BorderSide(color: TColors.background3),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("treatment")
                                .doc(alarmSettings.id.toString())
                                .delete();
                            Alarm.stop(alarmSettings.id)
                                .then((_) => Navigator.pop(context));
                          },
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('Mark as taken'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
