import 'dart:async';

import 'package:demeassist/screens/home.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResendMail extends StatefulWidget {
  @override
  _ResendMailState createState() => _ResendMailState();
}

class _ResendMailState extends State<ResendMail> {
  @override
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  @override
  void initState() {
    user = auth.currentUser;
    user.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      emailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> emailVerified() async {
    this.user = this.auth.currentUser;
    await this.user.reload();
    if (user.emailVerified) {
      timer.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
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
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.50,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('images/verify.png')),
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(
                    // padding: const EdgeInsets.only(top: 50),
                    padding: EdgeInsets.all(50),
                    child: Text(
                      "An email has been\nsent.Please check \nthe inbox.",
                      style: TextStyle(
                          color: primaryViolet,
                          fontSize: 25,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SpinKitCubeGrid(
                    color: primaryViolet,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
