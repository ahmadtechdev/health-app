import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grohealth/screens/user/user_home_screen.dart';
import 'package:grohealth/screens/welcome_screen.dart';

import 'colors.dart';
import 'firebase_options.dart';

import 'package:alarm/alarm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'dart:async';
import 'dart:io';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await AndroidAlarmManager.initialize();
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //
  // var initializationSettingsAndroid = AndroidInitializationSettings('doctor');
  // var initializationSettingsIOS = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //     onDidReceiveLocalNotification:
  //         (int id, String? title, String? body, String? payload) async {});
  // var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onDidReceiveNotificationResponse: (payload) async {
  //       if (payload != null) {
  //         debugPrint('notification payload: ' + payload.toString());
  //       }
  //     });

  await Alarm.init(showDebugLogs: true);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    return GetMaterialApp(
      title: 'Gro Health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
      ),
      home: user != null ? UserHome() : WelcomeScreen(),
    );
  }
}