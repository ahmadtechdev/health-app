import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import 'add_fitness_screen.dart';
import 'admin_home_screen.dart';
import 'fitness_info_screen.dart';

class FitnessPlan extends StatefulWidget {
  const FitnessPlan({super.key});

  @override
  State<FitnessPlan> createState() => _FitnessPlanState();
}

class _FitnessPlanState extends State<FitnessPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.off(AdminHome());
          },
        ),
        centerTitle: true,
        backgroundColor: primary,
        title: const Text(
          "Diet & Fitness",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: wColor,
      ),
      backgroundColor: primary,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("fitness")
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
                  var name = snapshot.data!.docs[index]['title'];
                  var time = snapshot.data!.docs[index]['createdAT'];
                  var desc = snapshot.data!.docs[index]['desc'];

                  var docId = snapshot.data!.docs[index].id;
                  var imageUrl = "assets/images/diet_icon.png";

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => FitnessInfo(), arguments: {
                        "title": name,
                        "description": desc,
                        'id': docId,
                        'time': time,
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
                          desc,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("fitness")
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
          Get.to(() => const AddFitnessScreen());
        },
        child: const Icon(
          Icons.add,
          color: primary,
        ),
      ),
    );
  }
}
