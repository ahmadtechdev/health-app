import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../colors.dart';
import '../../hospital_info.dart';
import 'user_hospital_type.dart';

class UserHospitalsPublic extends StatefulWidget {
  const UserHospitalsPublic({super.key});

  @override
  State<UserHospitalsPublic> createState() => _UserHospitalsPublicState();
}

class _UserHospitalsPublicState extends State<UserHospitalsPublic> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.to(UserHospitalType());
          },
        ),

        centerTitle: true,
        backgroundColor: primary,

        title: const Text("Public Hospitals", style: TextStyle(fontWeight: FontWeight.bold),),
        foregroundColor: wColor,
      ),
      backgroundColor: primary,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("hospitals")
            .where("type", isEqualTo: "Public")
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
            return const Center(child: Text("No data Found!"));
          }

          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var name = snapshot.data!.docs[index]['Name'];
                  var location = snapshot.data!.docs[index]['location'];
                  var category = snapshot.data!.docs[index]['category'];
                  var contact = snapshot.data!.docs[index]['phone'];
                  var docId = snapshot.data!.docs[index].id;
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => HospitalInfo(), arguments: {
                        'name': name,
                        'category': category,
                        'location': location,
                        'contact': contact,
                        'docId': docId,
                      });
                    },
                    child: Card(
                      color: wColor.withOpacity(0.9),
                      child: ListTile(
                        leading: Image.asset(
                          "assets/images/hospital.png",
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
                          location,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 18),
                        ),

                      ),
                    ),
                  );
                });
          }
          return Container();
        },
      ),

    );
  }
}
