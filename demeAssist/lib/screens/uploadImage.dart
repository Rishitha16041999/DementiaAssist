import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/screens/viewImage.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';

// ignore: must_be_immutable
class UploadImage extends StatefulWidget {
  String docID;
  UploadImage({this.docID});
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File _image;
  bool disabled, showProgress;
  String email;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }

    setState(() {
      _image = image;
    });
    print(_image.lengthSync());

    var result = await FlutterImageCompress.compressWithFile(
      _image.absolute.path,
      minWidth: 2300,
      minHeight: 1500,
      quality: 94,
      rotate: 90,
      format: CompressFormat.jpeg,
    );

    setState(() {
      showProgress = false;
    });
    if (_image.path.length > 2)
      setState(() {
        disabled = false;
      });
    print(result.length);
  }

  @override
  void initState() {
    _image = File("");
    setState(() {
      disabled = true;
      showProgress = false;
    });
    print(widget.docID);
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("PatientDetails")
        .doc(widget.docID)
        .get()
        .then((value) => setState(() {
              email = value.data()['email'];
            }));
    super.initState();
  }

  void uploadImage(BuildContext context) async {
    setState(() {
      disabled = true;
    });
    String fileName = basename(_image.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    firebaseStorageRef.putFile(_image);
    UploadTask uploadTask = firebaseStorageRef.putFile(
        _image, SettableMetadata(contentType: 'image/jpeg'));

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => Container(
          child: CircularProgressIndicator(),
        ));
    String imageURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('ImageURL')
        .doc(email)
        .collection("URL")
        .add({
      "imageURL": imageURL,
      "uid": FirebaseAuth.instance.currentUser.uid,
    });
    Navigator.pop(context);
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
          "Upload Image".toUpperCase(),
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'images/uploadImage.png',
                  ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.height * 0.07,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: primaryViolet,
                ),
                onPressed: disabled
                    ? null
                    : () {
                        uploadImage(context);
                        setState(() {
                          showProgress = true;
                        });
                      },
                child: Text(
                  "Upload Image".toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: showProgress ? LinearProgressIndicator() : null,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewImage(
                    email: this.email,
                  ),
                ),
              );
            },
            child: FaIcon(
              FontAwesomeIcons.images,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          FloatingActionButton(
            onPressed: () {
              getImage();
            },
            child: FaIcon(
              FontAwesomeIcons.upload,
            ),
          ),
        ],
      ),
    );
  }
}
