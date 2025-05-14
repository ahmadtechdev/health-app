import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../widgets/btn.dart';

class ExampleAlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const ExampleAlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Get well soon with Your Dose...",
              style: TextStyle(color: wColor, fontSize: 22, fontWeight: FontWeight.bold),


            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RoundedButton(
                  onTap: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          0,
                          0,
                        ).add(const Duration(minutes: 10)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  title:"Snooze",
                  icon: Icons.snooze,
                  // Text(
                  //   "Snooze",
                  //   style: Theme.of(context).textTheme.titleLarge,
                  // ),
                ),
                RoundedButton(
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection("treatment")
                        .doc(alarmSettings.id.toString())
                        .delete();
                    Alarm.stop(alarmSettings.id)
                        .then((_) => Navigator.pop(context));
                  },
                  title: "Stop",
                  icon: Icons.stop,
                  // Text(
                  //   "Stop",
                  //   style: Theme.of(context).textTheme.titleLarge,
                  // ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
