import 'package:alarm/model/alarm_settings.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:alarm/alarm.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../colors.dart';
import '../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import '../admin/adminHospital/admin_hospital_type.dart';
import '../admin/admin_doctor_category.dart';
import '../admin/admin_home_screen.dart';
import 'admin_treatment_list.dart';
import 'home_treatment.dart';

class AdminTreatmentView extends StatefulWidget {
  const AdminTreatmentView({super.key});

  @override
  State<AdminTreatmentView> createState() => _AdminTreatmentViewState();
}

class _AdminTreatmentViewState extends State<AdminTreatmentView> {
  final now = DateTime.now();
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: DateTime.now(),
    assetAudioPath: 'assets/audio/alarm.wav',
    loopAudio: true,
    vibrate: true,
    volume: 0.8,
    fadeDuration: 3.0,
    notificationTitle: 'This is the title',
    notificationBody: 'This is the body',
    enableNotificationOnKill: true,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Add Dose Reminder",
              backButton: true,
              signOutIcon: false,
              backgroundColor: primary,
              foregroundColor:
                  wColor, // Example of using a different background color
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 180.0,
                      child: Lottie.asset("assets/Animation - doctors.json"),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    RoundedButton(
                        title: "Add Dose Reminder",
                        icon: Icons.add,
                        onTap: () async {
                          scheduleAlarm();
                          int alarmId = 1;
                          // AndroidAlarmManager.oneShot(Duration(seconds: 1), alarmId, fireAlarm);
                          await Alarm.set(
                            alarmSettings: alarmSettings.copyWith(
                              dateTime: DateTime(
                                now.year,
                                now.month,
                                now.day,
                                now.hour,
                                now.minute + 1,
                                0,
                                0,
                              ).add(const Duration(seconds: 10)),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          currentIndex: 0,
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

void scheduleAlarm() async {
  DateTime scheduleNotificationDateTime =
      DateTime.now().add(Duration(seconds: 10));

  // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //   'alarm_notif',
  //   'alarm_notif',
  //   channelDescription: 'Channel for Alarm notification',
  //   icon: 'doctor',
  //   sound: RawResourceAndroidNotificationSound('alarm'),
  //   largeIcon: DrawableResourceAndroidBitmap('doctor'),
  // );
  //
  // var platformChannelSpecifics = NotificationDetails(
  //   android: androidPlatformChannelSpecifics,
  // );
  // await flutterLocalNotificationsPlugin.show(
  //     0, "check", "Yes its working", platformChannelSpecifics);
}

// void fireAlarm() async {
//   print("Alarm Fired at ${DateTime.now()}");
//
//
//   await Alarm.set(alarmSettings: alarmSettings);
//
// }
