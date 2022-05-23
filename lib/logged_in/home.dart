import 'dart:io';

import 'package:attendanceapp/classes/bleconnections.dart';
import 'package:attendanceapp/logged_in/student/home.dart';
import 'package:attendanceapp/logged_in/teacher/home.dart';
import 'package:attendanceapp/logged_in/verification.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isEmailVerified;
  String emailid;


  @override
  void dispose() {
    super.dispose();
    Nearby().stopAdvertising();
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    String type = data['type'];
    String emailid = data['emailid'];
    isEmailVerified = data['isEmailVerified'];
    Widget homeScreen;
    if (type=='Student') {
      if (Platform.isAndroid) {
        //bleConnections().getPermissions();
        bleConnections().advertisement(emailid);
        print("advertising contact ${emailid}");
      }
    }

    homeScreen = type == 'Student' ? StudentHome() : TeacherHome();
    return isEmailVerified ? homeScreen : VerifyEmail();
  }
}

