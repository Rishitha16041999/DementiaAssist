import 'dart:io';

import 'package:demeassist/service/authService.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:connectivity/connectivity.dart';

class AddPatient extends StatefulWidget {
  @override
  _AddPatientState createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final AuthService authService = AuthService();

  String email = "";
  String error = "";
  final _formKey = GlobalKey<FormState>();

  var logger = Logger();

  String name = '';
  String gender = 'Male';
  int age = 0;
  int mobile = 0;
  int genderVal = 0;
  File _image;
  bool enabled = true;
  List errors;
  String imageUrl;
  bool isValidEmail(String email) {
    bool validEmailId = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return validEmailId == false ? true : false;
  }

  void _genderStateHandle(int val) {
    setState(() {
      genderVal = val;

      switch (genderVal) {
        case 0:
          gender = "Male";
          break;
        case 1:
          gender = "Female";
          break;
        case 2:
          gender = "Other";
          break;
        default:
      }
    });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });

    print('Image Path $_image');
  }

  Future<bool> addPatient(String patientName, String gender, int age,
      int mobile, String email, BuildContext context) async {
    try {
      String uid = FirebaseAuth.instance.currentUser.uid;
      String fileName = basename(_image.path);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      firebaseStorageRef.putFile(_image);
      UploadTask uploadTask = firebaseStorageRef.putFile(_image);

      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => print("Upload completed"));
      String imageURL = await taskSnapshot.ref.getDownloadURL();

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("User")
          .doc(uid)
          .collection("PatientDetails")
          .doc();
      FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (!snapshot.exists) {
            documentReference.set({
              "uid": uid,
              "patientName": patientName,
              "imageURL": imageURL,
              "mobile": mobile,
              "age": age,
              "gender": gender,
              "email": email,
              'distanceLimit': 5
            });
            // Navigator.pop(context);
          }
        },
      );
      DocumentReference documentReference1 =
          FirebaseFirestore.instance.collection("PatientDetails").doc();
      FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference1);
          if (!snapshot.exists) {
            documentReference1.set({
              "uid": uid,
              "patientName": patientName,
              "imageURL": imageURL,
              "mobile": mobile,
              "age": age,
              "gender": gender,
              "email": email
            });
            Navigator.pop(context);
          }
        },
      );
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: primaryViolet,
        ),
        backgroundColor: Colors.white10,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ADD PATIENT",
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: (_image != null)
                          ? FileImage(_image)
                          : AssetImage('images/User.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    right: -(MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          getImage();
                          if (_image.path == null)
                            setState(() {
                              imageUrl =
                                  "https://firebasestorage.googleapis.com/v0/b/demeassist.appspot.com/o/User.png?alt=media&token=c1237149-2251-430d-a714-2b0a0bfd3188";
                            });
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.camera,
                          size: 30,
                          color: primaryViolet,
                        ),
                        tooltip: "Upload image",
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Name must not be empty.';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {
                                name = val;
                              },
                            );
                          },
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Patient Name",
                            icon: FaIcon(
                              FontAwesomeIcons.user,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Age must not be empty.';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {
                                age = int.parse(val);
                              },
                            );
                          },
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: "Age",
                            icon: FaIcon(
                              FontAwesomeIcons.birthdayCake,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Mobile must not be empty.';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {
                                mobile = int.parse(val);
                              },
                            );
                          },
                          maxLength: 10,
                          controller: _mobileController,
                          decoration: InputDecoration(
                            labelText: "Mobile",
                            icon: FaIcon(
                              FontAwesomeIcons.phone,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Mobile must not be empty.';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(
                              () {
                                email = val.toString();
                              },
                            );
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            icon: FaIcon(
                              FontAwesomeIcons.mailBulk,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.10,
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.venusMars,
                              color: Colors.grey[500],
                            ),
                            Radio(
                              value: 0,
                              groupValue: genderVal,
                              onChanged: _genderStateHandle,
                              activeColor: primaryViolet,
                            ),
                            Text(
                              "Male",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Radio(
                              value: 1,
                              groupValue: genderVal,
                              onChanged: _genderStateHandle,
                              activeColor: primaryViolet,
                            ),
                            Text(
                              "Female",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Radio(
                              value: 2,
                              groupValue: genderVal,
                              onChanged: _genderStateHandle,
                              activeColor: primaryViolet,
                            ),
                            Text(
                              "Other",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: "Save patient details",
                            verticalOffset: 40,
                            child: GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState.validate())
                                  await addPatient(name, gender, age, mobile,
                                      email, context);
                              },
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                width: MediaQuery.of(context).size.width * 0.75,
                                decoration: BoxDecoration(
                                  color: primaryViolet,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "ADD PATIENT",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
