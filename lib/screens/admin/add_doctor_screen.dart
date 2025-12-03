// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import 'admin_doctor_category.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final locationController = TextEditingController();

  String _selectedGender = "Male";
  String _selectedCategory = "General";
  String? _selectedHospital;
  List<String> _hospitals = [];
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('hospitals').get();
    setState(() {
      _hospitals = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['Name'] as String? ?? '')
          .toList();
      _hospitals.insert(0, "No Hospital");
      print(_hospitals);
      _selectedHospital = _hospitals.isNotEmpty ? _hospitals[0] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Add Doctor",
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
                      height: 150.0,
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
                                  labelText: 'Doctor Name',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter a Doctor Name";
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
                                  prefixIcon: Icon(Icons.folder_special,
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
                            TextFormField(
                              controller: emailController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email,
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
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return "Please enter a valid Email address";
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
                            DropdownButtonFormField(
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.male,
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
                                  labelText: 'Gender',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              items: [
                                DropdownMenuItem(
                                  value: "Male",
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: "Female",
                                  child: Text("Female"),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender =
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
                                  labelText: 'Hospital',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              value: _selectedHospital,
                              hint: Text(
                                'Select Hospital',
                                style:
                                    TextStyle(color: primary.withOpacity(0.8)),
                              ),
                              items: _hospitals.map((hospital) {
                                return DropdownMenuItem<String>(
                                  value: hospital,
                                  child: Text(
                                    hospital,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedHospital = newValue!;
                                });
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
                                  labelText: 'Clinic Location',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ],
                        )),
                    RoundedButton(
                        title: "Add Doctor",
                        icon: Icons.local_hospital,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var name = nameController.text.trim();
                            var category = _selectedCategory.trim();
                            var email = emailController.text.trim();
                            var phone = phoneController.text.trim();
                            var gender = _selectedGender.trim();
                            var hospital = _selectedHospital;
                            var location = locationController.text.trim();
                            if (location.isEmpty) {
                              location = "No Clinic";
                            }

                            try {
                              // Query Firebase to check if a doctor with the same name and phone exists
                              var existingDoctor = await FirebaseFirestore
                                  .instance
                                  .collection("doctors")
                                  .where("name", isEqualTo: name)
                                  .get();

                              if (existingDoctor.docs.isNotEmpty) {
                                // If a doctor with the same name and phone exists, show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Doctor with the same name already exists"),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: 12, right: 20, left: 20),
                                  ),
                                );
                              } else {
                                // If no existing doctor found, proceed with adding the doctor
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: email, password: phone)
                                    .then(
                                        (UserCredential userCredential) async {
                                  // Get the new user's ID
                                  String doctorUserId =
                                      userCredential.user!.uid;

                                  // Save doctor information in the Firestore collection with the new user's ID
                                  await FirebaseFirestore.instance
                                      .collection("doctors")
                                      .doc(doctorUserId)
                                      .set({
                                    "createdAT": DateTime.now(),
                                    "userId": doctorUserId,
                                    "name": name,
                                    "category": category,
                                    "email": email,
                                    "phone": phone,
                                    "workingHospital": hospital,
                                    "gender": gender,
                                    "location": location,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Doctor Successfully Created"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 12, right: 20, left: 20),
                                    ),
                                  );

                                  Get.off(AdminDoctorCategory());
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Failed to create doctor: $error"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 12, right: 20, left: 20),
                                    ),
                                  );
                                });
                              }
                            } on FirebaseAuthException catch (e) {
                              String errorMessage = "Failed to create doctor account";
                              switch (e.code) {
                                case 'email-already-in-use':
                                  errorMessage = "This email is already registered";
                                  break;
                                case 'invalid-email':
                                  errorMessage = "The email address is invalid";
                                  break;
                                case 'weak-password':
                                  errorMessage = "The password is too weak";
                                  break;
                                case 'operation-not-allowed':
                                  errorMessage = "Account creation is not allowed";
                                  break;
                                default:
                                  errorMessage = e.message ?? "Failed to create doctor account";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: 12, right: 20, left: 20),
                                ),
                              );
                            } on FirebaseException catch (e) {
                              String errorMessage = "Failed to save doctor information";
                              switch (e.code) {
                                case 'permission-denied':
                                  errorMessage = "You do not have permission to perform this operation";
                                  break;
                                case 'unavailable':
                                  errorMessage = "The service is currently unavailable. Please try again later";
                                  break;
                                default:
                                  errorMessage = e.message ?? "Failed to save doctor information";
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: 12, right: 20, left: 20),
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
                                  margin: EdgeInsets.only(
                                      bottom: 12, right: 20, left: 20),
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
