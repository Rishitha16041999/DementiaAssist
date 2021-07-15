import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demeassist/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class MedicineRemainder extends StatefulWidget {
  @override
  _MedicineRemainderState createState() => _MedicineRemainderState();
}

class _MedicineRemainderState extends State<MedicineRemainder> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String name, dosage;
  String _setTime, _setDate;
  String _hour, _minute, _time;
  int val = 1;
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  String email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('PatientDetails')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) => setState(() {
              email = value.docs[0]['email'];
            }));
  }

  void _selectTime() async {
    // final TimeOfDay newTime = await showTimePicker(
    //   context: context,
    //   initialTime: _time,
    //   initialEntryMode: TimePickerEntryMode.input,
    // );
    // if (newTime != null) {
    //   setState(() {
    //     _time = newTime;
    //   });
    // }

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
      });
  }

//radiobutton
  int radioVal = -1;
  void ValueChange(int value) {
    setState(() {
      radioVal = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: primaryViolet,
          ),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            "ADD NEW REMINDER",
            style: TextStyle(
              color: primaryViolet,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              letterSpacing: 2,
            ),
          ),
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      maxLength: 25,
                      validator: (value) {
                        if (value.isEmpty) return "Not a valid Medicine name";
                        return null;
                      },
                      onChanged: (data) {
                        setState(() {
                          name = data;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Medicine name',
                        helperText: 'Enter medicine name',
                        border: OutlineInputBorder(),
                      ),
                      controller: _nameController,
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return "Not a valid Dosage";
                        return null;
                      },
                      onChanged: (data) {
                        setState(() {
                          dosage = data;
                        });
                      },
                      maxLength: 5,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        helperText: 'Enter dosage in mg',
                        border: OutlineInputBorder(),
                      ),
                      controller: _dosageController,
                    ),
                    SizedBox(height: 10.0),
                    DropdownButton(
                      value: val,
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Enter Medicine Type'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Tablet'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Capsule'),
                        ),
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Injection'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('Syrup'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          val = value;
                        });
                      },
                    ),
                    SizedBox(height: 15.0),
                    Text(
                      'Repeat on ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CheckboxGroup(
                      orientation: GroupedButtonsOrientation.HORIZONTAL,
                      margin: const EdgeInsets.only(left: 12.0),
                      onSelected: (List selected) => setState(() {
                        days = selected;
                      }),
                      labels: <String>[
                        "Sun",
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat",
                      ],
                      // checked: days,
                      itemBuilder: (Checkbox cb, Text txt, int i) {
                        return Column(
                          children: <Widget>[
                            cb,
                            txt,
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 15.0),
                    Text(
                      'Take Medicine : ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Radio(
                            value: 0,
                            groupValue: radioVal,
                            onChanged: ValueChange,
                          ),
                          new Text(
                            'Before food',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                          new Radio(
                            value: 1,
                            groupValue: radioVal,
                            onChanged: ValueChange,
                          ),
                          new Text(
                            'After food',
                            style: new TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ]),
                    SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: _selectTime,
                          child: Text('SELECT TIME'),
                          style: ElevatedButton.styleFrom(
                            primary: primaryViolet,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Selected time : ${selectedTime.hour}:${selectedTime.minute}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate())
                              addRemainderDetails(name, dosage, val, days,
                                  radioVal, selectedTime, context, email);
                          },
                          child: Text(
                            'SET REMINDER',
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: primaryViolet,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

addRemainderDetails(String name, String dosage, int type, List days,
    int radioVal, TimeOfDay time, BuildContext context, String email) {
  String typeVal;
  if (type == 2) typeVal = 'Tablet';
  if (type == 3) typeVal = 'Capsule';
  if (type == 4) typeVal = 'Injection';
  if (type == 5) typeVal = 'Syrup';
  FirebaseFirestore.instance
      .collection('MedicineRemainder')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection('Medicines')
      .add({
    'name': name,
    'dosage': dosage,
    'type': typeVal,
    'days': days,
    'takeMedicine': radioVal == 1 ? 'Before Food' : 'After Food',
    'time': {'hr': time.hour, 'min': time.minute, 'period': time.periodOffset},
    'email': email
  }).then((value) => Navigator.pop(context));
}
