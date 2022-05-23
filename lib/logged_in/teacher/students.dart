import 'package:attendanceapp/animations/fadeanimation.dart';
import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:attendanceapp/shared/formatting.dart';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EnrolledStudents extends StatefulWidget {
  @override
  _EnrolledStudentsState createState() => _EnrolledStudentsState();
}

class _EnrolledStudentsState extends State<EnrolledStudents> {
  TeacherSubjectsAndBatches _tSAB;
  Map _studentsMap = {};
  List<String> _students = [];
  List<String> _studentsVisible = [];
  String _subject = '';
  String _batch = '';
  String _error = '';
  String _userName = '';
  bool _removeStudents = false;
  final GlobalKey<ScaffoldState> _scaffoldKey= GlobalKey();

  Future setup(FirebaseUser user, String sub, String batchCopy) async {
    _tSAB = TeacherSubjectsAndBatches(user);
    _studentsMap = await _tSAB.getStudents(sub, batchCopy);
    if (_studentsMap == null) {
      _students = ['Couldn\'t get students, try again'];
    }
    else{
      _students = _studentsMap.keys.where((key) => key != 'Empty').toList();
      _studentsVisible = _students;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    _subject = data['subject'];
    _batch = data['batch'];
    _userName = data['userName'];
    return Scaffold(
        key: _scaffoldKey,
      body: Column(
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
                      Expanded(child: Text('Students', style: GoogleFonts.roboto(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
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
                      ),
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
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(6.5),
                          child: TextFormField(
                            decoration: authInputFormatting.copyWith(hintText: "Search By ID"),
                            onChanged: (val){
                              setState(() {
                                _studentsVisible = _students.where((student) => student.toLowerCase().startsWith(val.toLowerCase())).toList();
                              });
                            },
                          ),
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
                      SizedBox(width: 5,)
                    ],
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
                  future: setup(Provider.of<FirebaseUser>(context), _subject, _batch),
                  rememberFutureResult: true,
                  whenNotDone: LoadingData(),
                  whenDone: (arg) => studentList(),
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
                    title: Text(_userName, style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7), fontSize: 20,fontWeight: FontWeight.w500),),
                    subtitle: Text(Provider.of<FirebaseUser>(context).email, style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7), fontSize: 14),),
                    trailing: Icon(Icons.account_circle_outlined,color: Colors.black.withOpacity(0.5),size: 40,),
                  ),
                ),
              ),

              ListTile(
                title: Text('Add Student',style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),),
                onTap: () async{
                  Navigator.of(context).pop();
                  dynamic returnedData = await Navigator.pushNamed(context, '/addStudents', arguments: {'enrolledStudents' : _students, 'batch' : _batch, 'subject': _subject});
                  if(returnedData != null) {
                    if(_studentsMap['Empty']){
                      _studentsMap['Empty'] = false;
                    }
                    setState(() {
                      _studentsMap['${returnedData['studentAdded']}'] = false;
                      _students.add(returnedData['studentAdded']);
                      _studentsVisible.add(returnedData['studentAdded']);
                    });
                  }
                },
              ),

              ListTile(
                title: Text('Remove Student',style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),),
                onTap: (){
                  Navigator.of(context).pop();
                  setState(() {
                    _removeStudents = true;
                  });
                },
              ),
              ListTile(
                title: Text('Add Attendance',style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),),
                onTap: () async{
                  Navigator.of(context).pop();
                  await Navigator.pushNamed(context, '/addAttendance', arguments: {'enrolledStudents' : _students, 'subject' : _subject, 'batch' : _batch});
                },
              ),


            ],
          ),
        ),
      ),
    );
  }



  Widget studentList(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _studentsMap['Empty'] ? addStudentButton() : Container(),
          _removeStudents && !_studentsMap['Empty'] ? removeStudent() : Container(),
          _studentsMap['Empty'] ? SizedBox(height: 15,) : Container(),
          _studentsMap['Empty'] ? Expanded(child: Text('You Need To Add Students', style: GoogleFonts.roboto(color: Colors.red),),) : Expanded(
            child: ListView.builder(
              itemCount: _studentsVisible.length,
              itemBuilder: (context, index){
                return FadeAnimation(
                  0.35, Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () async{
                         if(_removeStudents){
                           showDialog(
                               context: context,
                               builder: (context){
                                 return Dialog(
                                   shape:  RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(20.0)
                                   ),
                                   child: Container(
                                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: <Widget>[
                                         SizedBox(height: 30,),
                                         Text('Are you sure you want to remove ${_studentsVisible[index]} ? This action can\'t be reverted.', textAlign: TextAlign.justify,),
                                         SizedBox(height: 20,),
                                         Row(
                                           children: <Widget>[
                                             Expanded(
                                               child: FlatButton(
                                                 child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.cyan),),
                                                 onPressed: (){
                                                   Navigator.of(context).pop();
                                                 },
                                               ),
                                             ),
                                             Expanded(
                                               child: FlatButton(
                                                 child: Text('Delete', style: GoogleFonts.roboto(color: Colors.cyan),),
                                                 onPressed: () async{
                                                   dynamic result = await _tSAB.deleteStudent(_subject, _batch, _studentsVisible[index]);
                                                   String deleted = _studentsVisible[index];
                                                   if(result == 'Success')
                                                   {
                                                     Navigator.of(context).pop();
                                                     setState(() {
                                                       _error = '';
                                                       _studentsVisible.remove(deleted);
                                                       _students.remove(deleted);
                                                       _studentsMap.removeWhere((key, value) => key == deleted);
                                                     });
                                                     if(_students.isEmpty){
                                                       setState(() {
                                                         _removeStudents = false;
                                                         _studentsMap['Empty'] = true;
                                                       });
                                                     }
                                                   }
                                                   else{
                                                     setState(() {
                                                       _error = "Couldn't delete ${_studentsVisible[index]}";
                                                     });
                                                     Navigator.of(context).pop();
                                                   }
                                                 },
                                               ),
                                             )
                                           ],
                                         )
                                       ],
                                     ),
                                   ),
                                 );
                               }
                           );
                         }
                         else{
                           if(_studentsMap[_studentsVisible[index]]){
                             Navigator.pushNamed(context, '/attendanceList', arguments: {
                               'teacherEmail' : Provider.of<FirebaseUser>(context, listen: false).email ,
                               'subject': _subject,
                               'batch' : _batch,
                               'studentEmail' : _studentsVisible[index],
                             });
                           }
                           else{
                             showDialog(
                                 context: context,
                                 builder: (context){
                               return Dialog(
                                 shape:  RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(20.0)
                                 ),
                                 child: Container(
                                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: <Widget>[
                                       SizedBox(height: 30,),
                                       Text('This enrollement has not been accepted by the student.', textAlign: TextAlign.justify,),
                                       SizedBox(height: 20,),
                                       FlatButton(
                                         child: Text('Close', style: GoogleFonts.roboto(color: Colors.cyan),),
                                         onPressed: (){
                                           Navigator.of(context).pop();
                                         },
                                       )
                                     ],
                                   ),
                                 ),
                               );
                             });
                           }
                         }
                        },
                        title: Row(
                          children: <Widget>[
                            Expanded(child: Text('${_studentsVisible[index]}', style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),)),
                            _removeStudents ? Icon(Icons.delete, color: Colors.grey[700],) : Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[700],),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget addStudentButton() {

    return GestureDetector(
      onTap:() async{
        dynamic data = await Navigator.pushNamed(context, '/addStudents', arguments: {'enrolledStudents' : _students, 'batch' : _batch, 'subject': _subject});
        print(data);
        if(data != null) {
          if(_studentsMap['Empty']){
            _studentsMap['Empty'] = false;
          }
          setState(() {
            _studentsMap['${data['studentAdded']}'] = false;
            _students.add(data['studentAdded']);
            _studentsVisible.add(data['studentAdded']);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.all(Radius.circular(50))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.add, color: Colors.white, size: 20,),
            SizedBox(width: 5,) ,
            Text('Student', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
          ],
        ),
      ),
    );
  }

  Widget removeStudent(){
    return Column(
      children: <Widget>[
        _error == '' ? Container() : Center(child: Text('$_error', style: GoogleFonts.roboto(color: Colors.red), textAlign: TextAlign.center,),),
        _error == '' ? Container() : SizedBox(height: 15,),
        GestureDetector(
          onTap:() {
            setState(() {
              _removeStudents = !_removeStudents;
              _error = '';
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            child: Center(child: Text('Done', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)),
          ),
        ),
      ],
    );
  }
}