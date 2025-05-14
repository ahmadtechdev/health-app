import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/btn.dart';
import 'diet_fitness_screen.dart';
import 'fitness_info_screen.dart';

class AddDietScreen extends StatefulWidget {
  const AddDietScreen({super.key});

  @override
  State<AddDietScreen> createState() => _AddDietScreenState();
}

class _AddDietScreenState extends State<AddDietScreen> {
  String fitnessTitle = Get.arguments['title'].toString();
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;
  final dietController = TextEditingController();
  final planController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Add Plan for $fitnessTitle",
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
                      height: 250.0,
                      child:
                      Lottie.asset("assets/Animation - fitness.json"),
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: dietController,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.title,
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
                                  labelText: 'Plan Title',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter a Plan Title";
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
                              controller: planController,
                              maxLines: 15,
                              style: const TextStyle(
                                  color: primary, fontSize: 17.0),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.description,
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
                                  labelText: 'Plan',
                                  labelStyle: TextStyle(
                                      color: primary.withOpacity(0.8))),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                          ],
                        )),
                    RoundedButton(
                        title: "Add Plan",
                        icon: Icons.local_hospital,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var planTitle = dietController.text.trim();

                            var plan = planController.text.trim();


                            try {
                              // Query Firebase to check if a doctor with the same name and phone exists
                              var existingDoctor = await FirebaseFirestore.instance
                                  .collection("diet")
                                  .where("planTitle", isEqualTo: planTitle)
                                  .get();

                              if (existingDoctor.docs.isNotEmpty) {
                                // If a doctor with the same name and phone exists, show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Plan Title already exists"),
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
                                    .collection("diet")
                                    .doc()
                                    .set({
                                  "createdAT": DateTime.now(),
                                  "userId": userId?.uid,
                                  "title": fitnessTitle,
                                  "planTitle": planTitle,
                                  "plan": plan,

                                }).then((value) => {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Plan Successfully Added"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(bottom: 12, right: 20, left: 20),
                                    ),
                                  ),
                                  Get.off(FitnessInfo(), arguments: {
                                    'title': fitnessTitle
                                  }),
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
