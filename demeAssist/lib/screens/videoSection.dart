import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/screens/viewGallery.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart';
import 'package:video_compress/video_compress.dart';

// ignore: must_be_immutable
class VideoSection extends StatefulWidget {
  String docID;
  VideoSection({this.docID});
  @override
  _VideoSectionState createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  File _video, _thumbNail;
  bool disabled, showProgress;
  VideoPlayerController playerController;
  VoidCallback listener;
  String email;
  String compressedPath;
  int length;

  Future getVideo() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (video == null) {
      return;
    }
    await VideoCompress.setLogLevel(0);
    setState(() {
      showProgress = true;
    });
    MediaInfo info = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true,
      includeAudio: true,
    );

    setState(() {
      _video = info.file;
      length = _video.lengthSync();
    });

    print(length);

    final thumbnailFile = await VideoCompress.getFileThumbnail(_video.path,
        quality: 50, // default(100)
        position: -1 // default(-1)
        );

    setState(() {
      _thumbNail = thumbnailFile;
      showProgress = false;
    });
    if (_video.path.length > 2)
      setState(() {
        disabled = false;
      });
    print(_video.path);
  }

  @override
  void initState() {
    _video = File("");
    listener = () {
      setState(() {});
    };
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

  void uploadVideo(BuildContext context) async {
    setState(() {
      disabled = true;
    });
    print(_video.path);
    String fileName = basename(_video.path);
    String thumbName = basename(_thumbNail.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    Reference firebaseStorageRef1 =
        FirebaseStorage.instance.ref().child(thumbName);
    firebaseStorageRef.putFile(_video);
    firebaseStorageRef1.putFile(_thumbNail);
    UploadTask uploadTask = firebaseStorageRef.putFile(
        _video, SettableMetadata(contentType: 'video/mp4'));
    UploadTask uploadTask1 = firebaseStorageRef1.putFile(
        _thumbNail, SettableMetadata(contentType: 'image/jpeg'));

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => Container(
          child: CircularProgressIndicator(),
        ));
    TaskSnapshot taskSnapshot1 = await uploadTask1
        .whenComplete(() => print("Thumbnail Upload completed"));
    String videoURL = await taskSnapshot.ref.getDownloadURL();
    String thumbURL = await taskSnapshot1.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('VideoURL')
        .doc(email)
        .collection("URL")
        .add({
      "videoURL": videoURL,
      "thumbnail": thumbURL,
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
          "Upload Video".toUpperCase(),
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
                    'images/videoUpload.png',
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
                        uploadVideo(context);
                        setState(() {
                          showProgress = true;
                        });
                      },
                child: Text(
                  "Upload Video".toUpperCase(),
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
                  builder: (context) => ViewGallery(
                    email: this.email,
                  ),
                ),
              );
            },
            child: FaIcon(
              FontAwesomeIcons.playCircle,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          FloatingActionButton(
            onPressed: () {
              getVideo();
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
