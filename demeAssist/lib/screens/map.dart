import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity/connectivity.dart';

// ignore: must_be_immutable
class Map extends StatefulWidget {
  String email, patientName;
  Map({this.email, this.patientName});
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  Completer<GoogleMapController> _controller = Completer();

  double lat, lng, homeLat, homeLng, distance, distanceLimit;
  FlutterLocalNotificationsPlugin fltrNotification;
  double checkLat, checkLng;
  int mobile;
  @override
  void initState() {
    super.initState();
    checkConnectivity();
    FirebaseFirestore.instance
        .collection('PatientDetails')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) => {
              setState(() {
                this.distanceLimit = value.docs[0]['distanceLimit'];
              })
            });

    FirebaseFirestore.instance
        .collection('LocationDetails')
        .where('email', isEqualTo: widget.email)
        .get()
        .then((value) => {
              setState(() {
                this.lat = value.docs[0]['latitude'];
                this.lng = value.docs[0]['longitude'];
                this.homeLat = value.docs[0]['home']['lat'];
                this.homeLng = value.docs[0]['home']['lng'];
              })
            })
        .then((value) => {
              setState(() {
                this.distance =
                    Geolocator.distanceBetween(homeLat, homeLng, lat, lng);
              })
            })
        .then((value) {
      var androidInitilize = new AndroidInitializationSettings('app_icon');
      var iOSinitilize = new IOSInitializationSettings();
      var initilizationsSettings = new InitializationSettings(
          android: androidInitilize, iOS: iOSinitilize);
      fltrNotification = new FlutterLocalNotificationsPlugin();
      fltrNotification.initialize(initilizationsSettings,
          onSelectNotification: notificationSelected);

      print("Distance " + distanceLimit.toString());

      () async {
        final androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: "Title of the notification",
          notificationText: "Text of the notification",
          notificationImportance: AndroidNotificationImportance.High,
          // Default is ic_launcher from folder mipmap
        );
        FlutterBackground.initialize();
        FlutterBackground.enableBackgroundExecution();
        bool success =
            await FlutterBackground.initialize(androidConfig: androidConfig);
        if (success) {
          if (distance > distanceLimit) showNotification();
        }
      }();

      // if (distance > distanceLimit) showNotification();
    });

    FirebaseFirestore.instance
        .collection('PatientDetails')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then(
          (value) => setState(
            () {
              this.mobile = value.docs[0]['mobile'];
            },
          ),
        );
  }

  Future showNotification() async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await fltrNotification.show(
      3,
      '${widget.patientName} have been came out of the home',
      'Do check his/her location',
      platform,
      payload: 'Your loved one is wandering',
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
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('LocationDetails')
                  .where('email', isEqualTo: widget.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: SpinKitCubeGrid(
                      color: primaryViolet,
                    ),
                  );
                else
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(snapshot.data.docs[0]['latitude'],
                          snapshot.data.docs[0]['longitude']),
                      zoom: 18.0,
                    ),
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationButtonEnabled: true,
                    markers: _createMarker(snapshot.data.docs[0]['latitude'],
                        snapshot.data.docs[0]['longitude']),
                  );
              },
            ),
          ),
          Container(
            height: 20,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('PatientDetails')
                  .where('uid',
                      isEqualTo: FirebaseAuth.instance.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Text("");
                else {
                  if (distance > snapshot.data.docs[0]['distanceLimit'])
                    showNotification();
                  else
                    print("no changes");

                  return Text("");
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // content: IconButton(
        //     icon: FaIcon(
        //       FontAwesomeIcons.phone,
        //       color: primaryViolet,
        //     ),
        //     tooltip: "Make a call",
        //     onPressed: () async {
        //       await launch('tel://$mobile');
        //     }),
        content: Text(
          payload,
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Set<Marker> _createMarker(double lat, double lng) {
    return <Marker>[
      Marker(
        markerId: MarkerId('patient'),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: "Patient"),
      ),
    ].toSet();
  }
}
