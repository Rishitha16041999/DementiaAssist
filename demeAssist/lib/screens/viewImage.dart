import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_viewer/image_viewer.dart';

// ignore: must_be_immutable
class ViewImage extends StatefulWidget {
  String email;
  ViewImage({this.email});
  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
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
          "Image Gallery".toUpperCase(),
          style: TextStyle(
            color: primaryViolet,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            letterSpacing: 2,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("ImageURL")
            .doc(widget.email)
            .collection("URL")
            .where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: SpinKitCubeGrid(
                color: primaryViolet,
              ),
            );
          else
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot urls = snapshot.data.documents[index];
                  print(urls['imageURL']);
                  return GestureDetector(
                    onLongPress: () {
                      HapticFeedback.vibrate();
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            color: primaryViolet,
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.white,
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('ImageURL')
                                        .doc(widget.email)
                                        .collection('URL')
                                        .doc(urls.id)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Delete Image".toUpperCase(),
                                    style: TextStyle(
                                      color: primaryViolet,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        child: Image.network(
                          urls['imageURL'],
                        ),
                      ),
                    ),
                  );
                });
        },
      ),
    );
  }
}
