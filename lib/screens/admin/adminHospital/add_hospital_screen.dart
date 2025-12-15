// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/btn.dart';
import 'admin_hospital_type.dart';

class AddHospitalScreen extends StatefulWidget {
  const AddHospitalScreen({super.key});

  @override
  State<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends State<AddHospitalScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final locationController = TextEditingController();
  String _selectedCategory = "General";
  String _selectedType = "Public";

  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Add Hospital",
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
                      height: 180.0,
                      child: Lottie.asset("assets/Animation - hospital.json"),
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
                                  prefixIcon: Icon(Icons.local_hospital,
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
                                  labelText: 'Hospital Name',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter a Name";
                                } else if (value.length < 3) {
                                  return 'Name must be more than 2 character';
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
                                  prefixIcon: Icon(Icons.category,
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
                                  labelText: 'Speciality',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              items: const [
                                DropdownMenuItem(
                                  value: "Dental",
                                  child: Text("Dental"),
                                ),
                                DropdownMenuItem(
                                  value: "Heart",
                                  child: Text("Heart"),
                                ),
                                DropdownMenuItem(
                                  value: "Eye",
                                  child: Text("Eye"),
                                ),
                                DropdownMenuItem(
                                  value: "Brain",
                                  child: Text("Brain"),
                                ),
                                DropdownMenuItem(
                                  value: "Ear",
                                  child: Text("Ear"),
                                ),
                                DropdownMenuItem(
                                  value: "General",
                                  child: Text("General"),
                                ),
                              ],
                              hint: Text(
                                "Speciality",
                                style:
                                    TextStyle(color: primary.withOpacity(0.8)),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory =
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
                                  prefixIcon: Icon(Icons.published_with_changes,
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
                                  labelText: 'Hospital Type',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              items: const [
                                DropdownMenuItem(
                                  value: "Public",
                                  child: Text("Public"),
                                ),
                                DropdownMenuItem(
                                  value: "Private",
                                  child: Text("Private"),
                                ),
                              ],
                              hint: Text(
                                "Hospital Type",
                                style:
                                    TextStyle(color: primary.withOpacity(0.8)),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedType =
                                      newValue!; // Update the selected value
                                });
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
                                  labelText: 'Contact No',
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
                                  prefixIcon: Icon(Icons.location_on,
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
                                  labelText: 'Address',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ],
                        )),
                    RoundedButton(
                        title: "Add Hospital",
                        icon: Icons.add,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var name = nameController.text.trim();
                            var category = _selectedCategory.trim();
                            var type = _selectedType.trim();
                            var phone = phoneController.text.trim();
                            var location = locationController.text.trim();

                            try {

                              var existingDoctor = await FirebaseFirestore.instance
                                  .collection("hospitals")
                                  .where("Name", isEqualTo: name)
                                  .where("location", isEqualTo: location)
                                  .get();
                              if (existingDoctor.docs.isNotEmpty) {
                                // If a doctor with the same name and phone exists, show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Hospital with the same Name and Location already exists"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
                                  ),
                                );
                              }else{
                                await FirebaseFirestore.instance
                                    .collection("hospitals")
                                    .doc()
                                    .set({
                                  "createdAT": DateTime.now(),
                                  "userId": userId?.uid,
                                  "Name": name,
                                  "category": category,
                                  "type": type,
                                  "phone": phone,
                                  "location": location,
                                }).then((value) => {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content:
                                      Text("Hospital Successfully Added"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 12,
                                          right: 20,
                                          left: 20),
                                    ),
                                  ),
                                  Get.off(AdminHospitalType()),
                                });
                              }


                            } on FirebaseException catch (e) {
                              String errorMessage = "Failed to add hospital";
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
                                  errorMessage = e.message ?? "Failed to add hospital. Please try again";
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
