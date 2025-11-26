import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../colors.dart';
import '../../widgets/tile.dart';
import '../../widgets/user_bottom_nav_bar.dart';
import 'set_treatment_alarm.dart';
import 'ring.dart';

class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({Key? key}) : super(key: key);

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();
}

class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
  late List<AlarmSettings> alarms;
  String name = "";
  String unit = "";
  String amount = "";
  static StreamSubscription<AlarmSettings>? subscription;

  @override
  void initState() {
    super.initState();
    if (Alarm.android) {
      checkAndroidNotificationPermission();
      checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  void loadAlarms() {
    final fetched = Alarm.getAlarms();
    fetched.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    setState(() {
      alarms = fetched;
    });
  }

  Future<void> _handleRefresh() async {
    loadAlarms();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExampleAlarmRingScreen(alarmSettings: alarmSettings),
      ),
    );
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: ExampleAlarmEditScreen(alarmSettings: settings),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  Future<void> checkAndroidNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      alarmPrint('Requesting notification permission...');
      final res = await Permission.notification.request();
      alarmPrint(
        'Notification permission ${res.isGranted ? '' : 'not '}granted.',
      );
    }
  }

  Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      alarmPrint('Requesting external storage permission...');
      final res = await Permission.storage.request();
      alarmPrint(
        'External storage permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      alarmPrint(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        elevation: 0,
        title: const Text(
          "Dose Reminders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 20),
                alarms.isNotEmpty ? _buildAlarmList() : _buildEmptyState(context),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToAlarmScreen(null),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.white,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Add Reminder'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar: const UserBottomNavBar(
      //   initialIndex: 1,
      // ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final nextAlarm = alarms.isNotEmpty ? alarms.first : null;
    final nextTime = nextAlarm != null
        ? TimeOfDay(
            hour: nextAlarm.dateTime.hour,
            minute: nextAlarm.dateTime.minute,
          ).format(context)
        : '--';

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
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nextAlarm != null ? "Next reminder" : "No reminders scheduled",
            style: const TextStyle(
              color: TColors.white,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextTime,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _headerInfoChip(
                  icon: Icons.medication_rounded,
                  label: '${alarms.length} active reminders',
                ),
                const SizedBox(width: 10),
                _headerInfoChip(
                  icon: Icons.history_toggle_off,
                  label: nextAlarm != null
                      ? '${nextAlarm.dateTime.month}/${nextAlarm.dateTime.day}'
                      : 'Add a reminder',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: TColors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alarms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection("treatment")
              .doc(alarm.id.toString())
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(TColors.primary),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return _errorTile(snapshot.error.toString());
            }
            final data = snapshot.data?.data();
            if (data == null) {
              return _errorTile('Reminder details missing');
            }
            final name = data['name'] as String? ?? "Dose";
            final unit = data['unit'] as String? ?? 'unit';
            final amount = (data['dose'] as String?)?.isNotEmpty == true
                ? data['dose'] as String
                : '?';

            return ExampleAlarmTile(
              key: Key(alarm.id.toString()),
              id: alarm.id.toString(),
              name: name,
              unit: unit,
              amount: amount,
              title: TimeOfDay(
                hour: alarm.dateTime.hour,
                minute: alarm.dateTime.minute,
              ).format(context),
              onPressed: () => navigateToAlarmScreen(alarm),
              onDismissed: () async {
                await FirebaseFirestore.instance
                    .collection("treatment")
                    .doc(alarm.id.toString())
                    .delete();
                Alarm.stop(alarm.id).then((_) => loadAlarms());
              },
            );
          },
        );
      },
    );
  }

  Widget _errorTile(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: TColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: TColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TColors.background3),
      ),
      child: Column(
        children: [
          Icon(
            MdiIcons.alarmPlus,
            size: 56,
            color: TColors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            "No dose reminders yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Stay consistent with your medication plan by creating a reminder.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => navigateToAlarmScreen(null),
            icon: const Icon(Icons.add_alarm_outlined),
            label: const Text('Create reminder'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TColors.primary,
              side: const BorderSide(color: TColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
