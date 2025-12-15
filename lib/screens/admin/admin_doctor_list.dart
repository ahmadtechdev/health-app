import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../colors.dart';
import '../doctor_info.dart';
import 'add_doctor_screen.dart';
import 'admin_doctor_category.dart';
import 'admin_doctor_info.dart';

class AdminDoctor extends StatefulWidget {
  const AdminDoctor({super.key});

  @override
  State<AdminDoctor> createState() => _AdminDoctorState();
}

class _AdminDoctorState extends State<AdminDoctor> {
  User? userId = FirebaseAuth.instance.currentUser;
  String category = Get.arguments['category'].toString();
  String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.off(AdminDoctorCategory());
          },
        ),
        centerTitle: true,
        backgroundColor: primary,
        title: const Text(
          "Doctors",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: wColor,
      ),
      backgroundColor: primary,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("doctors")
            .where("category", isEqualTo: category)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong!");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text(
              "No data Found!",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ));
          }

          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var name = snapshot.data!.docs[index]['name'];
                  var doctorId = snapshot.data!.docs[index]['userId'];
                  var location = snapshot.data!.docs[index]['location'];
                  var category = snapshot.data!.docs[index]['category'];
                  var contact = snapshot.data!.docs[index]['phone'];
                  var gender = snapshot.data!.docs[index]['gender'];
                  var hospital = snapshot.data!.docs[index]['workingHospital'];
                  var docId = snapshot.data!.docs[index].id;
                  if (gender == "Male") {
                    imageUrl = "assets/images/doctor-male.png";
                  } else {
                    imageUrl = "assets/images/doctor-female.png";
                  }
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AdminDoctorInfo(), arguments: {
                        'name': name,
                        'doctorId': doctorId,
                        'category': category,
                        'location': location,
                        'contact': contact,
                        'gender': gender,
                        'hospital': hospital,
                        'docId': docId,
                      });
                    },
                    child: Card(
                      color: wColor.withOpacity(0.9),
                      child: ListTile(
                        leading: Image.asset(
                          imageUrl,
                          fit: BoxFit.fill,
                        ), // Add an icon to the left side
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primary,
                              fontSize: 24), // Customize text style
                        ),
                        subtitle: Text(
                          contact,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("doctors")
                                .doc(docId)
                                .delete();
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red, // Change delete icon color
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddDoctorScreen());
        },
        child: const Icon(
          Icons.add,
          color: primary,
        ),
      ),
    );
  }
}
