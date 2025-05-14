import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../pharmacy_info.dart';
import 'add_pharmacy_screen.dart';
import 'admin_home_screen.dart';

class AdminPharmacy extends StatefulWidget {
  const AdminPharmacy({super.key});

  @override
  State<AdminPharmacy> createState() => _AdminPharmacyState();
}

class _AdminPharmacyState extends State<AdminPharmacy> {
  User? userId = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.to(AdminHome());
          },
        ),
        centerTitle: true,
        backgroundColor: primary,

        title: const Text("Pharmacies", style: TextStyle(fontWeight: FontWeight.bold),),
        foregroundColor: wColor,
      ),
      backgroundColor: primary,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("pharmacy")
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
                  var name = snapshot.data!.docs[index]['name'];
                  var location = snapshot.data!.docs[index]['location'];

                  var contact = snapshot.data!.docs[index]['phone'];
                  var rating = snapshot.data!.docs[index]['rating'];
                  var docId = snapshot.data!.docs[index].id;
                  int ratingInt = int.tryParse(rating) ?? 0;
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => PharmacyInfo(), arguments: {
                        'name': name,
                        'rating': rating,
                        'location': location,
                        'contact': contact,
                        'docId': docId,
                      });
                    },
                    child: Card(
                      color: wColor.withOpacity(0.9),
                      child: ListTile(
                        leading: Image.asset(
                          "assets/images/pharmacy.png",
                          fit: BoxFit.fill,
                        ), // Add an icon to the left side
                        title: Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primary,
                              fontSize: 24), // Customize text style
                        ),
                        subtitle: Row(
                          children: [
                            for (int i = 1; i <= ratingInt; i++)
                              Icon(
                                Icons.star,
                                color: Colors.amber, // Adjust color as desired
                                size: 18.0,
                              ),
                            if (ratingInt < 5)
                              for (int i = ratingInt + 1; i <= 5; i++)
                                Icon(
                                  Icons.star_border,
                                  color: Colors.amber, // Adjust color as desired
                                  size: 18.0,
                                ),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("pharmacy")
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
          Get.to(() => const AddPharmacyScreen());
        },
        child: const Icon(Icons.add,color: primary,),
      ),
    );
  }
}
