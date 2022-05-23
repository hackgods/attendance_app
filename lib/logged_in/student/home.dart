import 'dart:async';

import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/bleconnections.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:attendanceapp/shared/formatting.dart';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;


class StudentHome extends StatefulWidget {

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  StudentEnrollmentAndAttendance _sEAA;
  Map _enrollmentDetails = {};
  Map _enrollmentDetailsVisible = {};
  List _keys = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String userName = '';

  Future setup(FirebaseUser user) async{
    _sEAA = StudentEnrollmentAndAttendance(user);
    _enrollmentDetails = await _sEAA.enrollmentList();
    if(_enrollmentDetails == null){
      _enrollmentDetails = {'error' : {'subject' : "Couldn't load subject list", 'batch' : 'Try Again', 'teacherEmail' : ' '}};
    }
    _enrollmentDetailsVisible = Map.from(_enrollmentDetails)..removeWhere((key, value) => !value['active']);
    _keys = _enrollmentDetailsVisible.keys.toList();

    userName = await UserDataBase(user).userName();
    if(userName == null){
      userName = 'Can\'t Get Name';
    }

    if (mounted) setState(() {

    });
  }

  final Strategy strategy = Strategy.P2P_STAR;
  List<String> _nearbydevices = [];

  void discovery(String emailid) async  {
    try {
      bool a = await Nearby().startDiscovery(emailid, strategy,
          onEndpointFound: (id, name, serviceId) async {
            print('$name is nearby'); // the name here is an email
            setState(() {
              _nearbydevices.add(name);
              print(_nearbydevices);
            });
          }, onEndpointLost: (id) {
            print(id);
          });
      print('DISCOVERING: ${a.toString()}');
    } catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    super.dispose();
    Nearby().stopAdvertising();
    //Nearby().stopDiscovery();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(45, 60, 30, 50),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50)
                    )
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text('Subjects', style: GoogleFonts.roboto(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.all(Radius.circular(50))
                        ),
                        child: FlatButton.icon(
                          label: Text('Log Out', style: GoogleFonts.roboto(color: Colors.cyan, fontWeight: FontWeight.bold)),
                          icon: Icon(Icons.exit_to_app, color: Colors.cyan, size: 15,),
                          onPressed: () async {
                            dynamic result = await User().signOut();
                            if (result == null) {
                              Navigator.of(context).pushReplacementNamed('/authentication');
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(40, 130, 40, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    )],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(6.5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: authInputFormatting.copyWith(hintText: "Subject, Batch Or Teacher"),
                            onChanged: (val){
                              setState(() {
                                _enrollmentDetailsVisible = Map.from(_enrollmentDetails)..removeWhere((k, v) => !(
                                    (v['subject'].toString().toLowerCase().startsWith(val.toLowerCase()) ||
                                        v['teacherEmail'].toString().toLowerCase().startsWith(val.toLowerCase()) ||
                                        v['batch'].toString().toLowerCase().startsWith(val.toLowerCase())) && v['active']));
                                _keys = _enrollmentDetailsVisible.keys.toList();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.cyan),
                          onPressed: (){
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: false,
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => drawer()
                            );
                          },
                        ),
                        SizedBox(width: 5,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              child: EnhancedFutureBuilder(
                future: setup(Provider.of<FirebaseUser>(context)),
                rememberFutureResult: true,
                whenNotDone: LoadingScreen(),
                whenDone: (arg) => enrollmentList(),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget drawer() {

    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8,vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.cyan[700], Colors.cyan])),
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(userName, style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7), fontSize: 20,fontWeight: FontWeight.w500),),
                    subtitle: Text(Provider.of<FirebaseUser>(context).email, style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7), fontSize: 14),),
                    trailing: Icon(Icons.account_circle_outlined,color: Colors.black.withOpacity(0.5),size: 40,),
                  ),
                ),
              ),

              /*
                  ListTile(
                    title: Text('Account Settings'),
                    onTap: ()  {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/accountSettings');
                    },
                  ),

                   */

            ],
          ),
        ),
      ),
    );
  }

  Widget enrollmentList(){
    return ListView.builder(
      itemCount: _keys.length,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(vertical: 7),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                onTap: (){
                  Navigator.pushNamed(context, '/attendanceList', arguments: {
                    'teacherEmail' :_enrollmentDetailsVisible[_keys[index]]['teacherEmail'] ,
                    'subject': _enrollmentDetailsVisible[_keys[index]]['subject'],
                    'batch' : _enrollmentDetailsVisible[_keys[index]]['batch'],
                    'studentEmail' : Provider.of<FirebaseUser>(context, listen: false).email,
                  });
                },
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${_enrollmentDetailsVisible[_keys[index]]['subject']} (${_enrollmentDetailsVisible[_keys[index]]['batch']})', style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.9),fontWeight: FontWeight.w500),),
                          SizedBox(height: 5,),
                          Text('${_enrollmentDetailsVisible[_keys[index]]['teacherEmail']}', style: GoogleFonts.roboto(fontSize: 10, color: Colors.grey[700]),),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[700],)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
