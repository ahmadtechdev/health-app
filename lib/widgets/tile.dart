import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExampleAlarmTile extends StatelessWidget {
  final String title;
  final String name;
  final String unit;
  final String amount;
  final String id;



  final void Function() onPressed;
  final void Function()? onDismissed;

  const ExampleAlarmTile({
    Key? key,
    required this.title,
    required this.id,
    required this.name,
    required this.unit,
    required this.amount,

    required this.onPressed,
    this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: key!,
      direction: onDismissed != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        child: const Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: RawMaterialButton(

        onPressed: onPressed,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 0.08 * MediaQuery.of(context).size.width, // Adjusting icon size
                        ),
                        SizedBox(width: 10),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 0.06 * MediaQuery.of(context).size.width, // Adjusting font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      amount + " " + unit,
                      style: TextStyle(
                        fontSize: 0.05 * MediaQuery.of(context).size.width, // Adjusting font size
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 0.04 * MediaQuery.of(context).size.width, // Adjusting font size
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 0.08 * MediaQuery.of(context).size.width, // Adjusting icon size
                color: Colors.white,
              ),
            ],
          ),
        ),



      ),
    );
  }
}
