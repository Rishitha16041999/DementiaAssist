import 'package:demeassist/models/user.dart';
import 'package:demeassist/screens/home.dart';
import 'package:demeassist/screens/liquidSwipe.dart';
// import 'package:demeassist/screens/startScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    if (user == null)
      return LiquidSwipeScreen();
    else
      return Home();
  }
}
