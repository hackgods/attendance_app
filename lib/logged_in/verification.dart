import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String _success = ' ';

  final User _account = User();

  SendEmail() async {
    FirebaseUser user = Provider.of<FirebaseUser>(context, listen: false);
    await user.sendEmailVerification().then((value) => setState(() {
      _success = 'Verification Email Sent';
    }));
  }



  Check() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseUser user = await auth.currentUser();
      await user.reload();
      final FirebaseUser user1 = await auth.currentUser();
    UserDataBase userData = UserDataBase(user1) ;
    bool isEmailVerified = user1.isEmailVerified;

    dynamic type = await userData.userType();

    if(isEmailVerified) {
      Navigator.of(context).pushReplacementNamed('/home', arguments: {'type' : type, 'isEmailVerified' : isEmailVerified});
    } else {
      print("Not verified email user");
    }
    print(isEmailVerified);

  }


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //SendEmail();

    return Scaffold(
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
                        Expanded(child: Text('Email Verification', style: GoogleFonts.roboto(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
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
                ],
              ),
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 150),
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        _success == ' ' ? Container() : Center(child: Text('$_success', style: GoogleFonts.roboto(color: Colors.green), textAlign: TextAlign.center,),),
                        _success == ' ' ? Container() : SizedBox(height: 15,),
                        Text(
                          'Verify your email using the verification link sent on your signup email id. This is required to access your account and helps save us from spam accounts. Log in again after you verify your email.',
                          style: GoogleFonts.roboto(fontSize: 18),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 50,),
                        GestureDetector(
                          onTap:() async{
                            FirebaseUser user = Provider.of<FirebaseUser>(context, listen: false);
                            await user.sendEmailVerification().then((value) => setState(() {
                              _success = 'Verification Email Sent';
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.all(Radius.circular(50))
                            ),
                            child: Text('Send Verfication Email', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                          ),
                        ),

                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap:() async{
                            Check();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.all(Radius.circular(50))
                            ),
                            child: Text('Done', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ),
          ],
        )
    );
  }
}
