import 'package:attendanceapp/animations/fadeanimation.dart';
import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:attendanceapp/shared/formatting.dart';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Batches extends StatefulWidget {
  @override
  _BatchesState createState() => _BatchesState();
}

class _BatchesState extends State<Batches> {
  TeacherSubjectsAndBatches _tSAB;
  FirebaseUser _user;
  String _subject = '';
  String _error  = '';
  String _userName = "";
  String _batch = '';
  List<String> _batches = [];
  List<String> _batchesVisible = [];
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _delete = false;

  Future setup(FirebaseUser userCurrent, String sub) async{
    _user = userCurrent;
    _tSAB = TeacherSubjectsAndBatches(_user);
    _batches = await _tSAB.getBatches(sub);
    if(_batches == null){
      _batches = ["Couldn't get batches, try again"];
    }
    _batchesVisible = _batches;
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    _subject = data['subject'];
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
                      Expanded(child: Text('Batches', style: GoogleFonts.roboto(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
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
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(6.5),
                          child: TextFormField(
                            decoration: authInputFormatting.copyWith(hintText: "Search By Batch"),
                            onChanged: (val){
                              setState(() {
                                _batchesVisible = _batches.where((batch) => batch.toLowerCase().startsWith(val.toLowerCase())).toList();
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.cyan),
                        onPressed: () async{
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
                future: setup(Provider.of<FirebaseUser>(context), _subject),
                rememberFutureResult: true,
                whenNotDone: LoadingData(),
                whenDone: (arg) => batchList(),
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
                title: Text('Add Batch',style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),),
                onTap: () async{
                  Navigator.of(context).pop();
                  addBatchForm().then((onValue){
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: Text('Remove Batch',style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),),
                onTap: (){
                  Navigator.of(context).pop();
                  if(_batches[0] != 'Empty'){
                    setState(() {
                      _delete = true;
                    });
                  }
                },
              ),
              /*
                  ListTile(
                    title: Text('Account Settings'),
                    onTap: (){
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

  Widget batchList(){
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _batches[0] == "Empty" ? addBatchButton() : Container(),
          _delete && _batches[0] != 'Empty' ? deleteButton() : Container(),
          _batches[0] == 'Empty' ? Text('\n\nYou Need To Add Batches', style: GoogleFonts.roboto(color: Colors.red),) : Expanded(
            child: ListView.builder(
              itemCount: _batchesVisible.length,
              itemBuilder: (context, index){
                return FadeAnimation(
                  0.35, Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        onTap: () async{
                          if(!_delete){
                            Navigator.of(context).pushNamed('/enrolledStudents', arguments: {'subject' : _subject, 'batch' : _batchesVisible[index], 'userName' : _userName});
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
                                          Text('Are you sure you want to delete ${_batchesVisible[index]} ? This action can\'t be reverted.', textAlign: TextAlign.justify,),
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
                                                    dynamic result = await _tSAB.deleteBatch(_subject, _batchesVisible[index]);
                                                    String deleted = _batchesVisible[index];
                                                    if(result == 'Success')
                                                    {
                                                      Navigator.of(context).pop();
                                                      setState(() {
                                                        _error = '';
                                                        _batchesVisible.remove(deleted);
                                                        _batches.remove(deleted);
                                                      });
                                                      if(_batches.isEmpty){
                                                        setState(() {
                                                          _batches.add('Empty');
                                                          _delete = false;
                                                        });
                                                      }
                                                    }
                                                    else{
                                                      setState(() {
                                                        _error = "Couldn't delete ${_batchesVisible[index]}";
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
                        },
                        title: Row(
                          children: <Widget>[
                            Expanded(child: Text('${_batchesVisible[index]}', style: GoogleFonts.roboto(color: Colors.black.withOpacity(0.7),fontWeight: FontWeight.w500),)),
                            _delete ? Icon(Icons.delete, color: Colors.grey[700],) : Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[700],),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addBatchButton()
  {
    return GestureDetector(
      onTap:() async{
        addBatchForm().then((onValue){
          setState(() {});
        });
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
            Icon(Icons.add, color: Colors.white, size: 25,),
            SizedBox(width: 10,) ,
            Text('Add', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
          ],
        ),
      ),
    );
  }

  Widget deleteButton() {
    return Column(
      children: <Widget>[
        _error == ' ' ? Container() : Center(child: Text('$_error', style: GoogleFonts.roboto(color: Colors.red), textAlign: TextAlign.center,),),
        _error == ' ' ? Container() : SizedBox(height: 15,),
        GestureDetector(
          onTap:(){
            setState(() {
              _delete = false;
              _error = ' ';
            }
            );
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
                Icon(Icons.add, color: Colors.white, size: 25,),
                SizedBox(width: 10,) ,
                Text('Done', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future addBatchForm()
  {
    bool adding = false;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState){
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20.0)),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _error == ' ' ? Container() : Center(child: Text('$_error', style: GoogleFonts.roboto(color: Colors.red),)),
                          _error == ' ' ? Container() : SizedBox(height: 15,),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              boxShadow: [BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                blurRadius: 10,
                                offset: Offset(0, 10),
                              )],
                            ),
                            child: TextFormField(
                              decoration: authInputFormatting.copyWith(hintText: 'Add Batch Name'),
                              validator: (val) => val.isEmpty ? 'Batch Name Can\'t Be Empty' : null,
                              onChanged: (val) => _batch = val,
                            ),
                          ),
                          SizedBox(height: 15,),
                          adding ? Center(child: Text("Adding ..."),) : Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(child: Text("Add", style: GoogleFonts.roboto(color: Colors.white),)),
                                  ),
                                  onTap: () async{
                                    if(_formKey.currentState.validate())
                                    {
                                      setState(() {
                                        adding = true;
                                      });
                                      if(_batches.contains(_batch))
                                      {
                                        setState(() {
                                          _error = "Batch Already Present";
                                          adding = false;
                                        });
                                      }
                                      else
                                      {
                                        dynamic result = await _tSAB.addBatch(_subject, _batch);
                                        if(result ==  null)
                                        {
                                          setState(() {
                                            _error = "Something Went Wrong, Couldn't Add Batch";
                                            adding = false;
                                          });
                                        }
                                        else
                                        {
                                          if(_batches[0] == 'Empty'){
                                            setState((){
                                              _batches.clear();
                                              _batches.add(_batch);
                                              _error = ' ';
                                              adding = false;
                                            });
                                          }
                                          else{
                                            setState((){
                                              _batches.add(_batch);
                                              _error = ' ';
                                              adding = false;
                                            });
                                          }
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                    child: Center(child: Text("Done", style: GoogleFonts.roboto(color: Colors.white),)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _error = ' ';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                  ),
                ),
              ),
            );
          },
        );
      });
  }
}
