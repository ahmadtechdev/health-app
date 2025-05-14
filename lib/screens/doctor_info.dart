import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/btn.dart';

class DoctorInfo extends StatefulWidget {
  @override
  State<DoctorInfo> createState() => _DoctorInfoState();
}

class _DoctorInfoState extends State<DoctorInfo> {
  String category = '';
  String name = '';
  String doctorId = '';
  String gender = '';
  String contact = '';
  String location = '';
  String hospital = '';
  User? userId = FirebaseAuth.instance.currentUser;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    // Store arguments in state variables
    var args = Get.arguments;
    category = args['category'].toString();
    name = args['name'].toString();
    doctorId = args['doctorId'].toString();
    gender = args['gender'].toString();
    contact = args['contact'].toString();
    location = args['location'].toString();
    hospital = args['hospital'].toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  void _bookAppointment() async {
    if (selectedDate == null || selectedTime == null) {
      // Show a dialog or snackbar to inform the user to select date and time
      Get.snackbar('Error', 'Please select date and time for the appointment');
      return;
    }

    var documentSnapshot1 = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId?.uid)
        .get();

    var userName = documentSnapshot1.data()?['userName'];
    var userPhone = documentSnapshot1.data()?['userPhone'];
    var userEmail = documentSnapshot1.data()?['userEmail'];

    DateTime appointmentDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance.collection("appointments").doc().set({
        'doctorName': name,
        'doctorid': doctorId,
        'userName': userName,
        'userPhone': userPhone,
        'userEmail': userEmail,
        'createdAt': DateTime.now(),
        'appointmentDateTime': appointmentDateTime,
      }).then((value) => {
        FirebaseAuth.instance.signOut(),
        Get.off(() => DoctorInfo()),
      });
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData categoryIcon;
    switch (category) {
      case 'Dental':
        categoryIcon = MdiIcons.toothOutline;
        break;
      case 'Heart':
        categoryIcon = MdiIcons.heartPlus;
        break;
      case 'Eye':
        categoryIcon = MdiIcons.eye;
        break;
      case 'Brain':
        categoryIcon = MdiIcons.brain;
        break;
      case 'Ear':
        categoryIcon = MdiIcons.earHearing;
        break;
      default:
        categoryIcon = MdiIcons.hospitalMarker; // Default icon
        break;
    }
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Doctor Information",
              backButton: true,
              signOutIcon: false,
              backgroundColor: primary,
              foregroundColor: wColor, // Example of using a different background color
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.9),
                      primary.withOpacity(0.2),
                      primary.withOpacity(0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              alignment: Alignment.center,
              height: 170.0,
              child: Lottie.asset(
                "assets/Animation - doctors.json",
                width: 250,
                height: 100,
                fit: BoxFit.cover, // Adjust the fit property as needed
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(categoryIcon, color: Colors.red, size: 30),
                        SizedBox(width: 5),
                        Text(
                          "$category Doctor",
                          style: TextStyle(
                            fontSize: 18,
                            color: bColor.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [primary.withOpacity(0.4), primary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              MdiIcons.humanMaleFemale,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                gender,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              contact,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text("Clinic Information",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.4), primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.stethoscope,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      location,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text("Hospital Information",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.4), primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
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
              child: Row(
                children: [
                  Icon(
                    MdiIcons.hospitalBuilding,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    hospital,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundedButton(
                title: "Book Appointment",
                icon: Icons.verified_user_sharp,
                onTap: () async {
                  await _selectDate(context);
                  if (selectedDate != null) {
                    await _selectTime(context);
                  }
                  _bookAppointment();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
