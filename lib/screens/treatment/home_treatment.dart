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
import '../admin/adminHospital/admin_hospital_type.dart';
import '../admin/admin_doctor_category.dart';
import '../admin/admin_home_screen.dart';
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
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.to(AdminHome());
          },
        ),
        centerTitle: true,
        backgroundColor: primary,
        title: const Text(
          "Doses Reminders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: wColor,
      ),
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.builder(
                itemCount: alarms.length,
                // separatorBuilder: (context, index) => const Divider(height: 1, color: pColor,),
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("treatment")
                        .doc(alarms[index].id.toString())
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // If the Future is still loading, return a loading indicator or placeholder
                        return const CircularProgressIndicator(); // Replace this with your loading indicator widget
                      } else {
                        if (snapshot.hasError) {
                          // If there's an error, return an error message widget or handle it appropriately
                          return Text("Error: ${snapshot.error}");
                        } else {
                          // If the data is fetched successfully, extract and build the widget
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>;
                          final name = data['name'] ?? "Dose ?";
                          final unit = data['unit'];
                          final amount =
                              data['dose'] != "" ? data['dose'] : "?";

                          return ExampleAlarmTile(
                            key: Key(alarms[index].id.toString()),
                            id: alarms[index].id.toString(),
                            name: name,
                            unit: unit,
                            amount: amount,
                            title: TimeOfDay(
                              hour: alarms[index].dateTime.hour,
                              minute: alarms[index].dateTime.minute,
                            ).format(context),
                            onPressed: () =>
                                navigateToAlarmScreen(alarms[index]),
                            onDismissed: () async {
                              await FirebaseFirestore.instance
                                  .collection("treatment")
                                  .doc(alarms[index].id.toString())
                                  .delete();
                              Alarm.stop(alarms[index].id)
                                  .then((_) => loadAlarms());
                            },
                          );
                        }
                      }
                    },
                  );
                },
              )
            : Center(
                child: Text(
                  "No Doses Reminder Added",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: primary, width: 2.0))),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: wColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.pill),
              label: 'Treatment',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                MdiIcons.hospital,
              ),
              label: 'Hospitals',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.doctor),
              label: 'Doctors',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: primary,
          unselectedItemColor: y1Color,
          onTap: onTabTapped,
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    if (index == 0) {
      Get.to(() => AdminHome());
    } else if (index == 1) {
      Get.to(() => ExampleAlarmHomeScreen());
    } else if (index == 2) {
      Get.to(() => AdminHospitalType());
    } else if (index == 3) {
      Get.to(() => AdminDoctorCategory());
    }
  }
}
