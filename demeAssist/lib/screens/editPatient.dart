import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/screens/remainderResult.dart';
import 'package:demeassist/screens/voiceRecording.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class EditPatient extends StatefulWidget {
  String patientName, gender, imageURL, docID, email;
  int mobile, age;

  EditPatient(
      {this.patientName,
      this.gender,
      this.imageURL,
      this.mobile,
      this.age,
      this.docID,
      this.email});
  @override
  _EditPatientState createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _distanceController = TextEditingController();

  String name = '';
  String gender = 'Male';
  int age = 0;
  int mobile = 0;
  int genderVal = 0;
  File _image;
  bool enabled = true;
  List errors;
  String imageUrl;
  double distance;

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

  Future<bool> editPatient(String patientName, String gender, int age,
      int mobile, BuildContext context) async {
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

      await FirebaseFirestore.instance
          .collection("User")
          .doc(uid)
          .collection("PatientDetails")
          .doc(widget.docID)
          .update({
            "uid": uid,
            "patientName": patientName,
            "imageURL": imageURL,
            "mobile": mobile,
            "age": age,
            "gender": gender
          })
          .then((value) => print("Value updated"))
          .catchError((err) => print(err));
      // Navigator.pop(context);
      await FirebaseFirestore.instance
          .collection("PatientDetails")
          .doc()
          .update({
            "uid": uid,
            "patientName": patientName,
            "imageURL": imageURL,
            "mobile": mobile,
            "age": age,
            "gender": gender
          })
          .then((value) => print("Value updated"))
          .catchError((err) => print(err));
      Navigator.pop(context);

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.patientName;
    _mobileController.text = widget.mobile.toString();
    _ageController.text = widget.age.toString();
    gender = widget.gender;
    setState(() {
      this.name = widget.patientName;
      this.age = widget.age;
      this.gender = widget.gender;
      this.imageUrl = widget.imageURL;
      this.mobile = widget.mobile;
    });
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
          "EDIT PATIENT",
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
                          : NetworkImage(widget.imageURL),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.15,
                    right: -(MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      child: IconButton(
                        hoverColor: Colors.white,
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
                          maxLength: 10,
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
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: primaryViolet,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate())
                              await editPatient(
                                  name, gender, age, mobile, context);
                            // Navigator.pop(context);
                          },
                          child: Text(
                            "Edit Patient".toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: "Add distance Limit",
            onPressed: () {
              showMaterialModalBottomSheet(
                expand: false,
                context: context,
                backgroundColor: Colors.white,
                builder: (context) => Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Text(
                        "Enter the distance limit!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Form(
                        key: _formKey1,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.10,
                                right: MediaQuery.of(context).size.width * 0.10,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                maxLength: 3,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Distance must not be empty.';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(
                                    () {
                                      distance = double.parse(val);
                                    },
                                  );
                                },
                                controller: _distanceController,
                                decoration: InputDecoration(
                                  labelText: "Distance",
                                  icon: FaIcon(
                                    FontAwesomeIcons.sortNumericDownAlt,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              height: MediaQuery.of(context).size.height * 0.07,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: primaryViolet,
                                ),
                                onPressed: () {
                                  if (_formKey1.currentState.validate()) {
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(FirebaseAuth
                                            .instance.currentUser.uid)
                                        .collection('PatientDetails')
                                        .doc(widget.docID)
                                        .update({'distanceLimit': distance})
                                        .then(
                                          (value) => print('Distance updated'),
                                        )
                                        .then(
                                          (value) => FirebaseFirestore.instance
                                              .collection('PatientDetails')
                                              .where('uid',
                                                  isEqualTo: FirebaseAuth
                                                      .instance.currentUser.uid)
                                              .get()
                                              .then(
                                                (value) => {
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'PatientDetails')
                                                      .doc(value.docs[0].id)
                                                      .update(
                                                    {'distanceLimit': distance},
                                                  ).then(
                                                    (value) => print(
                                                        'Distance updated'),
                                                  ),
                                                },
                                              ),
                                        );
                                  }
                                },
                                child: Text(
                                  "Add Distance limit".toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            child: FaIcon(
              FontAwesomeIcons.peopleArrows,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RemainderResult(),
                ),
              );
            },
            child: FaIcon(
              FontAwesomeIcons.clock,
            ),
          ),
        ],
      ),
    );
  }
}
