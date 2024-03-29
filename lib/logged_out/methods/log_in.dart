import 'package:attendanceapp/animations/fadeanimation.dart';
import 'package:attendanceapp/classes/account.dart';
import 'package:attendanceapp/classes/firestore.dart';
import 'package:attendanceapp/shared/formatting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  final ValueChanged<bool> updateTitle;
  Login(this.updateTitle);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final User _account = User();
  final _formKey = GlobalKey<FormState>();



  String _email;
  String _pass;
  String _error = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context){
    return loginForm();
  }

  Widget loginForm(){
    return _loading ? AuthLoading(185, 20) : Column(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 45, 0, 5),
            child: Column(
              children: <Widget>[
                FadeAnimation(
                  0.35, Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      )],
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[200]))
                          ),
                          child: TextFormField(
                            decoration: authInputFormatting.copyWith(hintText: "Enter Email"),
                            validator: _account.validateId,
                            onChanged: (val){
                              _email = val;
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey[200]))
                          ),
                          child: TextFormField(
                            decoration: authInputFormatting.copyWith(hintText: "Enter Password"),
                            validator: _account.validateLoginPass,
                            obscureText: true,
                            onChanged: (val){
                              _pass = val;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Text(_error, style: GoogleFonts.roboto(color: Colors.red),),
                SizedBox(height: 30,),
                FadeAnimation(
                  0.35, GestureDetector(
                    onTap: () async{
                      if(_formKey.currentState.validate())
                      {
                        setState(() => _loading = true);
                        FirebaseUser user = await _account.login(_email, _pass);
                        if(user != null)
                        {
                          bool isEmailVerified = user.isEmailVerified;
                          dynamic type = await UserDataBase(user).userType();
                          if(type != null){
                            Navigator.of(context).pushReplacementNamed('/home', arguments: {'type' : type, 'isEmailVerified' : isEmailVerified,'emailid': user.email});
                          }
                          else{
                            await _account.signOut();
                            setState(() {
                              _loading = false;
                              _error = 'Couldn\'t get user type, try again';
                            });
                          }
                        }
                        else
                        {
                          setState(() {
                            _loading = false;
                            _error = 'Email and/or password is incorrect';
                          });
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.cyan,
                      ),
                      child: Center(
                        child: Text("Login", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 17),),
                      ),
                    ),
                  ),
                ),
                SizedBox(height : 30),
              ],
            ),
          ),
        ),
        FadeAnimation(
          0.35, GestureDetector(
            onTap: () => widget.updateTitle(false),
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.8),
              ),
              child: Center(
                child: Text("Register", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 17),),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
