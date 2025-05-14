// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';

class AddPharmacyScreen extends StatefulWidget {
  const AddPharmacyScreen({super.key});

  @override
  State<AddPharmacyScreen> createState() => _AddPharmacyScreenState();
}

class _AddPharmacyScreenState extends State<AddPharmacyScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final locationController = TextEditingController();
  final ratingController = TextEditingController();

  String _selectedRating = "Male";
  String _selectedCategory = "General";
  String? _selectedHospital;

  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Add Pharmacy",
              backButton: true,
              signOutIcon: false,
              backgroundColor: primary,
              foregroundColor:
              wColor, // Example of using a different background color
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 200.0,
                      child:
                      Lottie.asset("assets/Animation - pharmacy.json"),
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
                                  prefixIcon: Icon(Icons.person,
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
                                  labelText: 'Pharmacy Name',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter a Pharmacy Name";
                                } else if (value.length < 3) {
                                  return 'Name must be more than 2 character';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),

                            TextFormField(
                              controller: phoneController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone,
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
                                  labelText: 'Contact NO.',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                                RegExp regExp = RegExp(pattern);
                                if (value!.length == 10) {
                                  return 'Enter minimum 10 digit mobile number';
                                } else if (!regExp.hasMatch(value)) {
                                  return 'Please enter valid mobile number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),

                            TextFormField(
                              controller: locationController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.local_pharmacy,
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
                                  labelText: 'Pharmacy Location',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            DropdownButtonFormField(
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.star_rate,
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
                                  labelText: 'Rating',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              items: [
                                DropdownMenuItem(
                                  value: "1",
                                  child: Text("1"),
                                ),DropdownMenuItem(
                                  value: "2",
                                  child: Text("2"),
                                ),DropdownMenuItem(
                                  value: "3",
                                  child: Text("3"),
                                ),DropdownMenuItem(
                                  value: "4",
                                  child: Text("4"),
                                ),DropdownMenuItem(
                                  value: "5",
                                  child: Text("5"),
                                ),

                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRating =
                                  newValue!; // Update the selected value
                                });
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ],
                        )),
                    RoundedButton(
                        title: "Add Pharmacy",
                        icon: Icons.local_pharmacy,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var name = nameController.text.trim();

                            var phone = phoneController.text.trim();
                            var rating = _selectedRating.trim();

                            var location = locationController.text.trim();
                            if (location.isEmpty){
                              location="No Clinic";
                            }

                            try {
                              // Query Firebase to check if a doctor with the same name and phone exists
                              var existingDoctor = await FirebaseFirestore.instance
                                  .collection("pharmacy")
                                  .where("name", isEqualTo: name)
                                  .get();

                              if (existingDoctor.docs.isNotEmpty) {
                                // If a doctor with the same name and phone exists, show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Pharmacy with the same name already exists"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
                                  ),
                                );
                              } else {
                                // If no existing doctor found, proceed with adding the doctor
                                await FirebaseFirestore.instance
                                    .collection("pharmacy")
                                    .doc()
                                    .set({
                                  "createdAT": DateTime.now(),
                                  "userId": userId?.uid,
                                  "name": name,
                                  "phone": phone,
                                  "rating": rating,
                                  "location": location,
                                }).then((value) => {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Pharmacy Successfully Added"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
                                    ),
                                  ),
                                  Get.off(AddPharmacyScreen()),
                                });
                              }
                            } catch (e) {
                              print("Error $e");
                            }
                          }
                        }
                    ),
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
