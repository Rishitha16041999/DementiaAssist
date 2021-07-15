import 'package:demeassist/utils/colors.dart';
import 'package:flutter/material.dart';

class VoiceRecording extends StatefulWidget {
  @override
  _VoiceRecordingState createState() => _VoiceRecordingState();
}

class _VoiceRecordingState extends State<VoiceRecording> {
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
    );
  }
}
