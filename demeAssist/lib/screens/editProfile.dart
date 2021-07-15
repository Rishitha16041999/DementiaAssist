import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  String userName, gender, imageURL, mobile, age;
  bool edit = false;

  EditProfile(
      {this.age,
      this.gender,
      this.imageURL,
      this.mobile,
      this.userName,
      this.edit});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  String name = '';
  String gender = 'Male';
  String age = '';
  String mobile = '';
  int genderVal = 0;
  File _image;
  bool enabled = true;
  List errors;
  String imageUrl;
  bool edit;

  String img;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = widget.userName;
    _mobileController.text = widget.mobile.toString();
    _ageController.text = widget.age.toString();
    gender = widget.gender;
    setState(() {
      this.name = widget.userName;
      this.age = widget.age;
      this.gender = widget.gender;
      this.imageUrl = widget.imageURL;
      this.mobile = widget.mobile;
      this.edit = widget.edit;
    });
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

  Future<bool> addUser(String userName, String gender, String age,
      String mobile, BuildContext context, bool edit) async {
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

      if (edit == true)
        FirebaseFirestore.instance
            .collection('User')
            .doc('UserDetails')
            .collection('UserDetails')
            .doc()
            .update({
          'uid': uid,
          "userName": userName,
          "imageURL": imageURL,
          "mobile": mobile,
          "age": age,
          "gender": gender,
        });
      else {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection("User")
            .doc(uid)
            .collection("UserDetails")
            .doc();
        FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(documentReference);
          if (!snapshot.exists) {
            documentReference.set({
              "uid": uid,
              "userName": userName,
              "imageURL": imageURL,
              "mobile": mobile,
              "age": age,
              "gender": gender,
            });
            Navigator.pushReplacementNamed(context, '/home');
            return true;
          }
        });
      }
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
          "EDIT PROFILE",
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
                          : edit == true
                              ? NetworkImage(this.imageUrl)
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
                        hoverColor: Colors.white,
                        onPressed: () {
                          getImage();
                          if (_image.path == null)
                            setState(() {
                              imageUrl = widget.imageURL;
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
                            labelText: "User Name",
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
                                age = val;
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
                                mobile = val;
                              },
                            );
                          },
                          controller: _mobileController,
                          maxLength: 10,
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
                        height: MediaQuery.of(context).size.height * 0.17,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: "Save details",
                            verticalOffset: 40,
                            child: GestureDetector(
                              onTap: () async {
                                await addUser(name, gender, age, mobile,
                                    context, widget.edit);
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
                                    "SAVE PROFILE",
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
            ],
          ),
        ),
      ),
    );
  }
}
