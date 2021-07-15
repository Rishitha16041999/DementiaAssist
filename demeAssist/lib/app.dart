import 'package:demeassist/models/user.dart';
import 'package:demeassist/screens/addPatient.dart';
import 'package:demeassist/screens/auth.dart';
import 'package:demeassist/screens/editPatient.dart';
import 'package:demeassist/screens/editProfile.dart';
import 'package:demeassist/screens/home.dart';
import 'package:demeassist/screens/login.dart';
import 'package:demeassist/screens/register.dart';
import 'package:demeassist/screens/resendMail.dart';
import 'package:demeassist/screens/wrapper.dart';
import 'package:demeassist/service/authService.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: primaryViolet,
          accentColor: primaryViolet,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Wrapper(),
        routes: {
          '/home': (context) => Home(),
          '/login': (context) => Login(),
          '/register': (context) => Register(),
          '/addPatient': (context) => AddPatient(),
          '/editPatient': (context) => EditPatient(),
          '/resendMail': (context) => ResendMail(),
          '/editUser': (context) => EditProfile(),
          '/auth': (context) => Authentication(),
        },
      ),
    );
  }
}
