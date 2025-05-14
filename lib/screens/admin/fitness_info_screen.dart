import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import 'add_diet_screen.dart';
import 'diet_fitness_screen.dart';
import 'diet_info_screen.dart';

class FitnessInfo extends StatefulWidget {
  const FitnessInfo({super.key});

  @override
  State<FitnessInfo> createState() => _FitnessInfoState();
}

class _FitnessInfoState extends State<FitnessInfo> {
  String dietTitle = Get.arguments['title'].toString();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to specific screen when back button in app bar is pressed
            Get.off(FitnessPlan());
          },
        ),
        centerTitle: true,
        backgroundColor: primary,
        title: Text(
          "$dietTitle Plan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: wColor,
      ),
      backgroundColor: primary,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("diet")
            .where("title", isEqualTo: dietTitle)
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
                  var name = snapshot.data!.docs[index]['planTitle'];
                  var time = snapshot.data!.docs[index]['createdAT'];
                  var plan = snapshot.data!.docs[index]['plan'];


                  var docId = snapshot.data!.docs[index].id;
                  var imageUrl = "assets/images/diet1.png";

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DietInfoScreen(), arguments: {
                        "title": name,
                        "plan": plan,
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
                          "click to read",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("diet")
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
          Get.to(() => AddDietScreen(), arguments: {
            "title": dietTitle,
          });
        },
        child: const Icon(
          Icons.add,
          color: primary,
        ),
      ),
    );
  }
}
