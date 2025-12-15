import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../colors.dart';
import '../../../widgets/app_bar.dart';
import '../../authentication/signin_screen.dart';
import '../../hospital_info.dart';
import '../../pharcmacy old.dart';

class AdminHospital extends StatefulWidget {
  const AdminHospital({super.key});

  @override
  State<AdminHospital> createState() => _AdminHospitalState();
}

class _AdminHospitalState extends State<AdminHospital> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primary,
        title: const Text("Doctors"),
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
            .collection("hospitals")
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
                  var name = snapshot.data!.docs[index]['Name'];
                  var location = snapshot.data!.docs[index]['location'];
                  var category = snapshot.data!.docs[index]['category'];
                  var contact = snapshot.data!.docs[index]['phone'];
                  var docId = snapshot.data!.docs[index].id;
                  return Card(
                    child: ListTile(
                      title: GestureDetector(
                          onTap: () {
                            Get.to(() => HospitalInfo(), arguments: {
                              'name': name,
                              'category': category,
                              'location': location,
                              'contact': contact,
                              'docId': docId,
                            });
                          },
                          child: Text(name)),
                      subtitle: Text(location),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("hospitals")
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
          Get.to(() => const AddHospitalScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
