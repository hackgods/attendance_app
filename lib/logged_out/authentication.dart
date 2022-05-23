import 'package:attendanceapp/const/screenconfig.dart';
import 'package:attendanceapp/logged_out/methods/log_in.dart';
import 'package:attendanceapp/logged_out/methods/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> with SingleTickerProviderStateMixin{
  bool _login = true;

  List<Color> colorList = [
    Colors.cyan[500],
    Colors.cyan[300],
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.cyan[500];
  Color topColor = Colors.black.withOpacity(0.8);
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;



  _updateTitle(bool login){
    setState(() => _login = login);
  }



  @override
  Widget build(BuildContext context) {

      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted) setState(() {
          bottomColor = Colors.black.withOpacity(0.9);
        });
      });


    return Scaffold(
      backgroundColor: Colors.cyan[500],
      body: AnimatedContainer(
        duration: Duration(seconds: 3),
        onEnd: () {
          setState(() {
            index = index + 1;
            // animate the color
            bottomColor = colorList[index % colorList.length];
            topColor = colorList[(index + 1) % colorList.length];

            //// animate the alignment
            begin = alignmentList[index % alignmentList.length];
            end = alignmentList[(index + 2) % alignmentList.length];
          });
        },
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: begin, end: end, colors: [bottomColor, topColor])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 70, 15, 0),
              child: Text('${_login ? 'Login' : 'Register'}', style: GoogleFonts.roboto(color: Colors.white, fontSize: 50, letterSpacing: 2, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(38, 0, 15, 0),
              child: Text('${_login ? 'Hello Welcome' : 'Create an account'}', style: GoogleFonts.roboto(color: Colors.white, fontSize: 22,),),
            ),
            Expanded(
              child: Container(
                clipBehavior: Clip.hardEdge,
                height: screenHeight(context)/3,
                margin: EdgeInsets.fromLTRB(15, 70, 15, 20),
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50), topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50),bottomLeft: Radius.circular(50),
                    )
                ),
                child: ListView(
                  children: <Widget>[
                    _login ? Login(_updateTitle) : Register(_updateTitle),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}