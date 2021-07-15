import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/screens/info.dart';
import 'package:demeassist/screens/patientWrapper.dart';
import 'package:demeassist/screens/userProfile.dart';
import 'package:demeassist/screens/wrapper.dart';
import 'package:demeassist/service/authService.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

const simpleTaskKey = "simpleTask";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}");

        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService authService = AuthService();

  final _user = FirebaseFirestore.instance;

  String uid = FirebaseAuth.instance.currentUser.uid;

  bool found = false;
  int hr, mins;
  String name, dosage, type, patientName, takeMedicine;

  FlutterLocalNotificationsPlugin fltrNotification;

  Future<bool> patientFound() async {
    DocumentReference documentReference =
        _user.collection('PatientDetails').doc();
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      if (!snapshot.exists)
        setState(() {
          this.found = true;
        });
      else
        setState(() {
          this.found = false;
        });
    });
    return this.found;
  }

  @override
  void initState() {
    super.initState();
    // () async {
    //   await BackgroundLocation.setAndroidNotification(
    //     title: "DemeAssist is running in background",
    //     message: "This helps you to inform about patient",
    //     icon: "@mipmap/app_icon",
    //   );
    // }();
    checkConnectivity();
    tz.initializeTimeZones();

    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);

    // Workmanager.initialize(
    //   callbackDispatcher,
    //   isInDebugMode: true,
    // );
    // Workmanager.registerOneOffTask(
    //   "1",
    //   simpleTaskKey,
    // );
    //

    FirebaseFirestore.instance
        .collection("PatientDetails")
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        patientName = value.docs[0]['patientName'];
      });
    });

    FirebaseFirestore.instance
        .collection('MedicineRemainder')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('Medicines')
        .get()
        .then((value) => {
              setState(() {
                hr = value.docs[0]['time']['hr'];
                mins = value.docs[0]['time']['min'];
                name = value.docs[0]['name'];
                dosage = value.docs[0]['dosage'];
                takeMedicine = value.docs[0]['takeMedicine'];
                type = value.docs[0]['type'];
              })
            })
        .then((value) {
      print(hr);
      print(mins);
    }).then((value) => {
              print("Medicine remainder Started"),
              alarmNotification(
                  hr, mins, name, dosage, takeMedicine, type, patientName),
            });
  }

  alarmNotification(
      int hr, int min, String name, dosage, takeMedicine, type, patientName) {
    _showNotification(hr, min, name, dosage, takeMedicine, type, patientName);
  }

  Future _showNotification(int hr, int min, String name, dosage, takeMedicine,
      type, patientName) async {
    var time = Time(hr, min - 1, 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      "CHANNEL_DESCRIPTION 4",
      importance: Importance.max,
      priority: Priority.max,
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await fltrNotification.showDailyAtTime(
      0,
      'Hi $patientName!!! Time to take the medicine $name.',
      'Medicine type $type. Dosgae $dosage', //null
      time,
      platformChannelSpecifics,
      payload: takeMedicine,
    );
  }

  checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)))
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 50,
            title: Text(
              "No internet connectivity 🤦‍♂️",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              "Please connect the device to internet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          );
        },
      );
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
            "HOME",
            style: TextStyle(
              color: primaryViolet,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              letterSpacing: 2,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfile(),
                  ),
                );
              },
              tooltip: "Profile",
              icon: FaIcon(FontAwesomeIcons.userCircle),
            ),
            IconButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Wrapper(),
                  ),
                );
              },
              tooltip: "Logout",
              icon: FaIcon(FontAwesomeIcons.signOutAlt),
            ),
          ],
        ),
        body: Container(
          child: !found
              ? StreamBuilder(
                  stream: _user
                      .collection('User')
                      .doc(uid)
                      .collection("PatientDetails")
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
                          DocumentSnapshot patienDetails =
                              snapshot.data.documents[index];
                          String _id = patienDetails.id;
                          return Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientWrapper(
                                      age: patienDetails['age'],
                                      gender: patienDetails['gender'],
                                      imageURL: patienDetails['imageURL'],
                                      mobile: patienDetails['mobile'],
                                      patientName: patienDetails['patientName'],
                                      docID: _id,
                                      email: patienDetails['email'],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                semanticContainer: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                elevation: 8,
                                margin: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.06),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Container(
                                    margin: EdgeInsets.all(
                                      MediaQuery.of(context).size.height * 0.02,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              child: CircleAvatar(
                                                maxRadius: 60,
                                                backgroundImage: NetworkImage(
                                                    patienDetails['imageURL']),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.10,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      patienDetails[
                                                          'patientName'],
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                ),
                                                Text(
                                                  patienDetails['mobile']
                                                      .toString(),
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                ),
                                                Text(
                                                  patienDetails['age']
                                                      .toString(),
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                ),
                                                Text(
                                                  patienDetails['gender'],
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                  },
                )
              : Text(
                  "Please add patient details.",
                  style: TextStyle(color: Colors.black),
                ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: "About Dementia",
              verticalOffset: 40,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Info(),
                    ),
                  );
                },
                child: FaIcon(
                  FontAwesomeIcons.infoCircle,
                ),
                backgroundColor: primaryViolet,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Tooltip(
              message: "Add Patient",
              verticalOffset: 40,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed((context), '/addPatient');
                },
                child: FaIcon(
                  FontAwesomeIcons.plus,
                ),
                backgroundColor: primaryViolet,
              ),
            ),
          ],
        ));
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Time to take medicine $payload"),
      ),
    );
  }
}

void showAlarm() {
  print('object');
}
