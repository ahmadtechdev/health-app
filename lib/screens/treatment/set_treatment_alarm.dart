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
  final _formKey = GlobalKey<FormState>();
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
    } on FirebaseException catch (e) {
      String errorMessage = "Failed to save alarm";
      switch (e.code) {
        case 'permission-denied':
          errorMessage = "You do not have permission to perform this operation";
          break;
        case 'unavailable':
          errorMessage = "The service is currently unavailable. Please try again later";
          break;
        case 'deadline-exceeded':
          errorMessage = "The operation took too long. Please try again";
          break;
        default:
          errorMessage = e.message ?? "Failed to save alarm. Please try again";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
        ),
      );
      setState(() => loading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred. Please try again"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
        ),
      );
      setState(() => loading = false);
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
    final title = creating ? 'Create Reminder' : 'Update Reminder';
    return Container(
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: TColors.greyLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getDay(),
                    style: TextStyle(
                      color: TColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: pickTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: TColors.background3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reminder time',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                TimeOfDay.fromDateTime(selectedDateTime)
                                    .format(context),
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.schedule_rounded,
                                  color: TColors.accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSwitchTile(
                    title: 'Loop alarm audio',
                    value: loopAudio,
                    onChanged: (value) => setState(() => loopAudio = value),
                  ),
                  _buildSwitchTile(
                    title: 'Vibrate',
                    value: vibrate,
                    onChanged: (value) => setState(() => vibrate = value),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: nameController,
                    label: 'Medicine name',
                    hint: 'e.g., Vitamin D',
                    icon: Icons.drive_file_rename_outline,
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a medicine name'
                            : null,
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Unit',
                    value: _selectedUnit,
                    icon: Icons.medication_liquid_rounded,
                    onChanged: (value) =>
                        setState(() => _selectedUnit = value ?? _selectedUnit),
                    items: const [
                      "gram(s)",
                      "injection(s)",
                      "pill(s)",
                      "tablespoon(s)",
                      "drops(s)",
                      "capsule(s)",
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    label: 'Frequency',
                    value: _selectedTimePeriod,
                    icon: Icons.repeat_rounded,
                    onChanged: (value) => setState(
                        () => _selectedTimePeriod = value ?? _selectedTimePeriod),
                    items: const [
                      "daily",
                      "weekly",
                      "demand",
                    ],
                    itemLabels: const {
                      "daily": "Daily",
                      "weekly": "Weekly",
                      "demand": "On demand (no reminder)",
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: amountController,
                    label: 'Amount',
                    hint: 'e.g., 2',
                    icon: Icons.numbers_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildSwitchTile(
                    title: 'Custom volume',
                    value: volume != null,
                    onChanged: (value) =>
                        setState(() => volume = value ? 0.5 : null),
                  ),
                  if (volume != null)
                    Row(
                      children: [
                        Icon(
                          volume! > 0.7
                              ? Icons.volume_up_rounded
                              : volume! > 0.1
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_mute_rounded,
                          color: TColors.textSecondary,
                        ),
                        Expanded(
                          child: Slider(
                            activeColor: TColors.primary,
                            value: volume!,
                            onChanged: (value) =>
                                setState(() => volume = value),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TColors.textSecondary,
                            side: const BorderSide(color: TColors.background3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    saveAlarm();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        TColors.white),
                                  ),
                                )
                              : const Text('Save reminder'),
                        ),
                      ),
                    ],
                  ),
                  if (!creating) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: deleteAlarm,
                        child: const Text(
                          'Delete reminder',
                          style: TextStyle(color: TColors.error),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.background3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: value,
            activeColor: TColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: TColors.accent),
        filled: true,
        fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.accent, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required List<String> items,
    Map<String, String>? itemLabels,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: TColors.accent),
        filled: true,
        fillColor: TColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: TColors.background3),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: TColors.textSecondary),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(itemLabels?[e] ?? e),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
