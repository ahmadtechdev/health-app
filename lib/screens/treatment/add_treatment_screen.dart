// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import 'admin_treatment_list.dart';

class AddDoseScreen extends StatefulWidget {
  const AddDoseScreen({super.key});

  @override
  State<AddDoseScreen> createState() => _AddDoseScreenState();
}

class _AddDoseScreenState extends State<AddDoseScreen> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  final timeController = TextEditingController();

  String _selectedTimePeriod = "Once daily";
  String _selectedUnit = "capsule(s)";
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;

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
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: nameController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
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
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
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
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.ad_units,
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
                                  labelText: 'Unit',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
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
                                style:
                                TextStyle(color: primary.withOpacity(0.8)),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUnit =
                                  newValue!; // Update the selected value
                                });
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            DropdownButtonFormField(
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.timeline,
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
                                  labelText: 'How often do you take this medication?',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),

                              items: const [
                                DropdownMenuItem(
                                  value: "daily1",
                                  child: Text("Once daily"),
                                ),
                                DropdownMenuItem(
                                  value: "daily2",
                                  child: Text("Twice daily"),
                                ),
                                DropdownMenuItem(
                                  value: "demand",
                                  child: Text("On demand (no reminder needed)"),
                                ),

                              ],
                              hint: Text(
                                "daily dose limit",
                                style:
                                TextStyle(color: primary.withOpacity(0.8)),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTimePeriod =
                                  newValue!; // Update the selected value
                                });
                              },
                            ),

                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: timeController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.timelapse,
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
                                  labelText: 'Time',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              onTap: () async {
                                TimeOfDay time = TimeOfDay.now();
                                FocusScope.of(context).requestFocus(new FocusNode());

                                TimeOfDay? picked =
                                await showTimePicker(context: context, initialTime: time);
                                if (picked != null && picked != time) {
                                  timeController.text = picked.format(context).toString();  // add this line.
                                  setState(() {
                                    time = picked;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: amountController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.auto_mode,
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
                                  labelText: 'Amount',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 30.0,
                    ),
                    RoundedButton(
                        title: "Add Dose Reminder",
                        icon: Icons.add,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var name = nameController.text.trim();
                            var timePeriod = _selectedTimePeriod.trim();
                            var unit = _selectedUnit.trim();
                            var time = timeController.text.trim();
                            var dose = amountController.text.trim();

                            try {
                              await FirebaseFirestore.instance
                                  .collection("treatment")
                                  .doc()
                                  .set({
                                "createdAT": DateTime.now(),
                                "userId": userId?.uid,
                                "name": name,
                                "timePeriod":timePeriod,
                                "unit": unit,
                                "time": time,
                                "dose": dose,
                              }).then((value) => {
                                Get.off(AdminTreatment()),
                              });
                            } catch (e) {
                              print("Error $e");
                            }

                          }
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
    );
  }
}
