import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:demeassist/screens/editPatient.dart';
import 'package:demeassist/screens/map.dart';
import 'package:demeassist/screens/medicineRemainder.dart';
import 'package:demeassist/screens/uploadImage.dart';
import 'package:demeassist/screens/videoSection.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:flutter/material.dart';

class PatientWrapper extends StatefulWidget {
  String patientName, gender, imageURL, docID, email;
  int mobile, age;

  PatientWrapper(
      {this.patientName,
      this.gender,
      this.imageURL,
      this.mobile,
      this.age,
      this.docID,
      this.email});
  @override
  _PatientWrapperState createState() => _PatientWrapperState();
}

class _PatientWrapperState extends State<PatientWrapper> {
  static String patientName, gender, imageURL, docID, email;
  static int mobile, age;
  @override
  void initState() {
    super.initState();
    patientName = widget.patientName;
    gender = widget.gender;
    imageURL = widget.imageURL;
    mobile = widget.mobile;
    age = widget.age;
    email = widget.email;
    docID = widget.docID;
  }

  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  List screensList = [
    EditPatient(
        patientName: patientName,
        gender: gender,
        imageURL: imageURL,
        mobile: mobile,
        age: age,
        docID: docID,
        email: email),
    Map(email: email, patientName: patientName),
    MedicineRemainder(),
    VideoSection(
      docID: docID,
    ),
    UploadImage(
      docID: docID,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screensList[_page],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        color: primaryViolet,
        backgroundColor: Colors.white,
        height: MediaQuery.of(context).size.height * 0.07,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        items: [
          Icon(
            Icons.edit_attributes_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.elderly_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.video_collection_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.cloud_upload_rounded,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}
