import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/bleconnections.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;


class AddAttendance extends StatefulWidget {
  @override
  _AddAttendanceState createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  bool _chooseClass = true;
  DateTime _current = DateTime.now();
  String _date = '';
  String _start = '';
  String _end = '';
  String _subject, _batch;
  String _error = ' ';
  List<String> _enrolledStudents = [];
  Map _attendance = {};
  TeacherSubjectsAndBatches _tSAB;
  final Strategy strategy = Strategy.P2P_STAR;

  void discovery(String emailid) async {
    try {
      bool a = await Nearby().startDiscovery(emailid, strategy,
          onEndpointFound: (id, name, serviceId) async {
            print('$name is present in class'); // the name here is an email
            setState(() {
              _attendance[name] = !_attendance[name];
              print(_attendance);
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
  Widget build(BuildContext context) {


    Map data = ModalRoute.of(context).settings.arguments;
    _subject = data['subject'];
    _batch = data['batch'];
    _enrolledStudents = data['enrolledStudents'];
    _attendance = _attendance.isEmpty ? Map.fromIterable(_enrolledStudents, key: (student) => student, value: (student) => false ) : _attendance;
    _tSAB = TeacherSubjectsAndBatches(Provider.of<FirebaseUser>(context));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(5, 60, 30, 50),
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50)
                      )
                  ),
                  child: Row(
                    children: <Widget>[
                      BackButton(color: Colors.white70,),
                      Expanded(child: Text('${_chooseClass? 'Class Timing':'Add Attendance'}', style: GoogleFonts.roboto(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
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
              ],
            ),
          ),
          SizedBox(height: 5,),
          Expanded(child: _chooseClass ? chooseClassDuration() : addAttendance()),
        ],
      ),
    );
  }

  Widget chooseClassDuration(){
    dynamic fieldTextStyle = GoogleFonts.roboto(color: Colors.cyan, fontSize: 17, fontWeight: FontWeight.w400);
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            )],
          ),
          margin: EdgeInsets.fromLTRB(20, 100, 20, 25),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today,),
                    SizedBox(width: 20,),
                    Expanded(child: _date.isEmpty ? Text('Choose Class Date', style: fieldTextStyle,) : Text('$_date', style: fieldTextStyle)),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey[700],),
                      onPressed: (){
                          DatePicker.showDatePicker(
                          context,
                          theme: DatePickerTheme(containerHeight: 350, backgroundColor: Colors.white,),
                          showTitleActions: true,
                          minTime: DateTime(_current.year, _current.month - 1, _current.day),
                          maxTime: DateTime(_current.year, _current.month, _current.day),
                          onConfirm: (dt) {
                            setState(() {
                              _date =dt.toString().substring(0,10);
                            });
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.access_time,),
                    SizedBox(width: 20,),
                    Expanded(child: _start.isEmpty ? Text('Choose Start Time', style: fieldTextStyle,) : Text('$_start', style: fieldTextStyle,)),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey[700],),
                      onPressed: (){
                        DatePicker.showTime12hPicker(
                          context,
                          theme: DatePickerTheme(containerHeight: 300, backgroundColor: Colors.white,),
                          showTitleActions: true,
                          onConfirm: (time) {
                            setState(() {
                              _start = DateFormat.jm().format(time);
                            });
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.access_time,),
                    SizedBox(width: 20,),
                    Expanded(child: _end.isEmpty ? Text('Choose Stop Time', style: fieldTextStyle,) : Text('$_end', style: fieldTextStyle,)),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey[700],),
                      onPressed: (){
                        DatePicker.showTime12hPicker(
                          context,
                          theme: DatePickerTheme(containerHeight: 240, backgroundColor: Colors.white,),
                          showTitleActions: true,
                          onConfirm: (time) {
                            setState(() {
                              _end = DateFormat.jm().format(time);
                            });
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        _error == ' ' ? Container() :  Text('$_error', style: GoogleFonts.roboto(color: Colors.red),),
        _error == ' ' ? Container() :  SizedBox(height: 20,),
        Container(
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 70),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.cyan[300],
          ),
          child: Center(
            child: FlatButton(
              onPressed: (){
                if(_date.isNotEmpty && _start.isNotEmpty && _start.isNotEmpty)
                {
                  setState(() {
                    _chooseClass = false;
                    _error = ' ';
                  });
                }
                else{
                  setState(() {
                    _error = 'All three fields are required';
                  });
                }
              },
              child: Text('Submit',style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 17),),
            ),
          ),
        ),
      ],
    );
  }

  Widget addAttendance(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Platform.isAndroid ? Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.cyan[300],
            ),
            child: Center(
                child: FlatButton(
                  onPressed: () async{
                    //bleConnections().getPermissions();
                    //bleConnections().advertisement(Provider.of<FirebaseUser>(context,listen: false).email);
                    discovery(Provider.of<FirebaseUser>(context,listen: false).email);

                  },
                  child: Text('Auto Add Students', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 17),),
                )
            ),
          ) : SizedBox(),

          _error == ' ' ? Container() :  Text('$_error', style: GoogleFonts.roboto(color: Colors.red),),
          Expanded(
            child: ListView.builder(
              itemCount: _enrolledStudents.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text('${_enrolledStudents[index]}', style: GoogleFonts.roboto(color: _attendance[_enrolledStudents[index]] ? Colors.green : Colors.red),),
                        ),
                        IconButton(
                          icon: _attendance[_enrolledStudents[index]] ? Icon(Icons.check_circle_outline, color: Colors.green,) : Icon(Icons.highlight_off_outlined, color: Colors.red,),
                          onPressed: () {
                            setState(() {
                              _attendance[_enrolledStudents[index]] = !_attendance[_enrolledStudents[index]];
                              print(_attendance);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 40,vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.cyan[300],
            ),
            child: Center(
              child: FlatButton(
                onPressed: () async{
                  String dateTime = _date + ' : ' + _start + ' - ' + _end;
                  dynamic result = await _tSAB.addAttendance(_subject, _batch, dateTime, _attendance);
                  if(result == null){
                    setState(() {
                      _error = 'Something went wrong try again';
                    });
                  }
                  else{
                    Navigator.pop(context);

                    if (Platform.isAndroid) {
                      //Nearby().stopAdvertising();
                      Nearby().stopDiscovery();
                    }
                  }
                },
                child: Text('Finish', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 17),),
              )
            ),
          ),
        ],
      ),
    );
  }
}
