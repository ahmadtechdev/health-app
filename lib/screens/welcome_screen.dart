import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../colors.dart';
import 'authentication/signin_screen.dart';


class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondary,
              primary,
              secondary
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: Column(
          children: [
            SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.all(20),
              child: Lottie.asset('assets/Animation - doctors.json')

            ),
            SizedBox(height: 40),
            Text(
              "DOCTOR'S ONLINE",
              style: TextStyle(
                color: wColor,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                wordSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Find Your Best Doctor",
              style: TextStyle(
                color: wColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 60),
            Material(
              color: wColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SignInScreen()
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical:15, horizontal:40),
                  child: Text("LET'S GO",style: TextStyle(
                    color:primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  ),


              ),

            ),


        ),
    SizedBox(height: 60),
    Image.asset('assets/images/lined heart.png',
        color: wColor,
        scale: 2,
    )

      ],
      ),
    ),
    );
  }
  }

