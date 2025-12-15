import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../colors.dart';
import '../doctor_info.dart';

class DoctorsList extends StatelessWidget {
  final String hospitalName;

  const DoctorsList({
    Key? key,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("doctors")
          .where("workingHospital", isEqualTo: hospitalName)
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
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "No data Found!",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        return SizedBox(
          height: 260, // Specify a fixed height for the ListView
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var name = snapshot.data!.docs[index]['name'];
              var location = snapshot.data!.docs[index]['location'];
              var category = snapshot.data!.docs[index]['category'];
              var contact = snapshot.data!.docs[index]['phone'];
              var gender = snapshot.data!.docs[index]['gender'];
              var hospital = snapshot.data!.docs[index]['workingHospital'];
              var docId = snapshot.data!.docs[index].id;
              String imageUrl = "";
              if (index % 2 == 0) {
                switch (gender) {
                  case 'Female':
                    imageUrl = "assets/images/doctor1.jpg";
                    break;
                  case 'Male':
                    imageUrl = "assets/images/doctor3.jpg";
                    break;
                  default:
                    imageUrl = "assets/images/doctor3.jpg"; // Default image
                    break;
                }
              } else {
                switch (gender) {
                  case 'Female':
                    imageUrl = "assets/images/doctor2.jpg";
                    break;
                  case 'Male':
                    imageUrl = "assets/images/doctor4.jpg";
                    break;
                  default:
                    imageUrl = "assets/images/doctor4.jpg"; // Default image
                    break;
                }
              }

              return GestureDetector(
                onTap: () {
                  Get.to(() => DoctorInfo(), arguments: {
                    'name': name,
                    'category': category,
                    'location': location,
                    'contact': contact,
                    'gender': gender,
                    'hospital': hospital,
                    'docId': docId,
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [primary.withOpacity(0.4), primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: primary,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: wColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          color: wColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
