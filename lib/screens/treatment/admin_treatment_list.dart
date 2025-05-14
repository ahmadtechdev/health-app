import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../authentication/signin_screen.dart';
import 'add_treatment_screen.dart';
import 'home_treatment.dart';

class AdminTreatment extends StatefulWidget {
  const AdminTreatment({super.key});

  @override
  State<AdminTreatment> createState() => _AdminTreatmentState();
}

class _AdminTreatmentState extends State<AdminTreatment> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primary,
        title: const Text("Treatment"),
        foregroundColor: wColor,
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Get.off(() => SignInScreen());
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("treatment")
            .where("userId", isEqualTo: userId?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong!");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data Found!"));
          }

          if (snapshot != null && snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var name = snapshot.data!.docs[index]['name'];
                  var unit = snapshot.data!.docs[index]['unit'];
                  var time_period = snapshot.data!.docs[index]['timePeriod'];
                  var time = snapshot.data!.docs[index]['time'].toString();
                  var dose = snapshot.data!.docs[index]['dose'];
                  var docId = snapshot.data!.docs[index].id;
                  return Card(
                    child: ListTile(
                      title: GestureDetector(
                          onTap: () {
                            Get.to(() => ExampleAlarmHomeScreen(),
                            //     arguments: {
                            //   'name': name,
                            //   'unit': unit,
                            //   'time_period': time_period,
                            //   'time': time,
                            //   'dose': dose,
                            //   'docId': docId,
                            // }
                            );
                          },
                          child: Text(name)),
                      subtitle: Text(time),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // GestureDetector(
                          //     onTap: () {
                          //       Get.to(() => EditNoteScreen(), arguments: {
                          //         'note': note,
                          //         'docId': docId,
                          //       });
                          //     },
                          //     child: Icon(Icons.edit)),
                          // SizedBox(
                          //   width: 10.0,
                          // ),
                          GestureDetector(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("treatment")
                                    .doc(docId)
                                    .delete();
                              },
                              child: Icon(Icons.delete)),
                        ],
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
          Get.to(() => const AddDoseScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
