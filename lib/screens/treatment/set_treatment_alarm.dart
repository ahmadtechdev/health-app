import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  const ExampleAlarmEditScreen({Key? key, this.alarmSettings})
      : super(key: key);

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  bool loading = false;
  String _selectedTimePeriod = "daily";
  String _selectedUnit = "capsule(s)";
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  int id=0;
  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late String assetAudio;
  User? userId = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      assetAudio = 'assets/audio/alarm.wav';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volume;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final DateTime now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {


    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      assetAudioPath: assetAudio,
      notificationTitle: nameController.text.trim().isEmpty ? "Dose Time" : "${nameController.text.trim()} Medicine Time",
      notificationBody: 'For your health, take your dose as directed',
    );
    return alarmSettings;
  }

  void saveAlarm() async {
    final id1 = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000
        : widget.alarmSettings!.id;
    id= id1;
    if (loading) return;
    setState(() => loading = true);
    var name = nameController.text.trim().isEmpty ? "Medicine" : nameController.text.trim();
    var timePeriod = _selectedTimePeriod.trim();
    var unit = _selectedUnit.trim();
    var dose = amountController.text.trim().isEmpty ? "1" : amountController.text.trim();

    try {
      await FirebaseFirestore.instance.collection("treatment").doc(id.toString()).set({
        "createdAT": DateTime.now(),
        "userId": userId?.uid,
        "name": name,
        "timePeriod": timePeriod,
        "unit": unit,
        "time": selectedDateTime,
        "dose": dose,
      }).then((value) => {
            Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
              if (res) Navigator.pop(context, true);
              setState(() => loading = false);
            })
          });
    } catch (e) {
      print("Error $e");
    }
  }

  void deleteAlarm() async {
    await FirebaseFirestore.instance
        .collection("treatment")
        .doc(widget.alarmSettings!.id.toString())
        .delete();
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: primary),
                  ),
                ),
                TextButton(
                  onPressed: saveAlarm,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(
                          "Save",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: primary),
                        ),
                ),
              ],
            ),
            Text(
              getDay(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: primary.withOpacity(0.8)),
            ),
            RawMaterialButton(
              onPressed: pickTime,
              fillColor: Colors.grey[200],
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  TimeOfDay.fromDateTime(selectedDateTime).format(context),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: primary),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loop alarm audio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: loopAudio,
                  onChanged: (value) => setState(() => loopAudio = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vibrate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: vibrate,
                  onChanged: (value) => setState(() => vibrate = value),
                ),
              ],
            ),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: primary, fontSize: 17.0),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.drive_file_rename_outline,
                      color: primary.withOpacity(0.6)),
                  // suffixIcon: Icon(Icons.email),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: primary.withOpacity(0.6),
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Medicine Name',
                  labelStyle: TextStyle(color: primary.withOpacity(0.8))),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a Medicine Name";
                }
                return null;
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            DropdownButtonFormField(
              style: const TextStyle(color: primary, fontSize: 17.0),
              decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.ad_units, color: primary.withOpacity(0.6)),
                  // suffixIcon: Icon(Icons.email),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: primary.withOpacity(0.6),
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Unit',
                  labelStyle: TextStyle(color: primary.withOpacity(0.8))),
              items: [
                DropdownMenuItem(
                  value: "gram(s)",
                  child: Text("gram(s)"),
                ),
                DropdownMenuItem(
                  value: "injection(s)",
                  child: Text("injection(s)"),
                ),
                DropdownMenuItem(
                  value: "pill(s)",
                  child: Text("pill(s)"),
                ),
                DropdownMenuItem(
                  value: "tablespoon(s)",
                  child: Text("tablespoon(s)"),
                ),
                DropdownMenuItem(
                  value: "drops(s)",
                  child: Text("drops(s)"),
                ),
                DropdownMenuItem(
                  value: "capsules(s)",
                  child: Text("capsules(s)"),
                ),
              ],
              hint: Text(
                "Unit",
                style: TextStyle(color: primary.withOpacity(0.8)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUnit = newValue!; // Update the selected value
                });
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            DropdownButtonFormField(
              isExpanded: true,
              style: const TextStyle(color: primary, fontSize: 17.0),
              decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.timeline, color: primary.withOpacity(0.6)),
                  // suffixIcon: Icon(Icons.email),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: primary.withOpacity(0.6),
                      width: 2.0,
                    ),
                  ),
                  labelText: 'How often do you take this medication?',
                  labelStyle: TextStyle(color: primary.withOpacity(0.8))),
              items: const [
                DropdownMenuItem(
                  value: "daily",
                  child: Text("Daily"),
                ),
                DropdownMenuItem(
                  value: "weekly",
                  child: Text("Weekly"),
                ),
                DropdownMenuItem(
                  value: "demand",
                  child: Text("On demand (no reminder needed)"),
                ),
              ],
              hint: Text(
                "daily dose limit",
                style: TextStyle(color: primary.withOpacity(0.8)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimePeriod = newValue!; // Update the selected value
                });
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            TextFormField(
              controller: amountController,
              style: const TextStyle(color: primary, fontSize: 17.0),
              decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.auto_mode, color: primary.withOpacity(0.6)),
                  // suffixIcon: Icon(Icons.email),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                      color: primary,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: primary.withOpacity(0.6),
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: primary.withOpacity(0.8))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom volume',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: volume != null,
                  onChanged: (value) =>
                      setState(() => volume = value ? 0.5 : null),
                ),
              ],
            ),
            SizedBox(
              height: 30,
              child: volume != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          volume! > 0.7
                              ? Icons.volume_up_rounded
                              : volume! > 0.1
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_mute_rounded,
                        ),
                        Expanded(
                          child: Slider(
                            value: volume!,
                            onChanged: (value) {
                              setState(() => volume = value);
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            if (!creating)
              TextButton(
                onPressed: deleteAlarm,
                child: Text(
                  'Delete Alarm',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.red),
                ),
              ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
