import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../colors.dart';

class SearchScan extends StatefulWidget {
  const SearchScan({super.key});

  @override
  State<SearchScan> createState() => _SearchScanState();
}

class _SearchScanState extends State<SearchScan> {
  String imageUrl='';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: primary,
        title: Text(
          "Add Product",
          style: TextStyle(
              color: wColor,
              fontSize: 25,
              fontWeight: FontWeight.w900),
        ),
        foregroundColor: wColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 9, // Set your desired height here
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      IconButton(onPressed: () async {
                        ImagePicker imagepicker = ImagePicker();
                        XFile? file = await imagepicker.pickImage(source: ImageSource.camera);
                        print('${file?.path}');

                        if(file==null) return;
                        String uniqueFilename = DateTime.now().microsecondsSinceEpoch.toString();
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference refrenceDirImages=referenceRoot.child('images');

                        Reference refrenceImageToUpload = refrenceDirImages.child(uniqueFilename);

                        try{
                          await refrenceImageToUpload.putFile(File(file!.path));
                          imageUrl=await refrenceImageToUpload.getDownloadURL();
                          print(imageUrl);
                        }catch(error){
                          print(error);
                        }


                      }, icon: Icon(Icons.camera_alt)),
                      SizedBox(height: 15),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  uploadImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    final imagePicker = ImagePicker();
    PickedFile image;
    //Check Permissions
    // Request permission for photos access
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted){
      //Select Image
      final image = await imagePicker.pickImage(source: ImageSource.gallery);


      if (image != null){
        var file = File(image.path);
        final imageName = image.name;
        //Upload to Firebase
        final uploadTask = firebaseStorage.ref().child('images/$imageName').putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);

        // Get the download URL after successful upload
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }
}
