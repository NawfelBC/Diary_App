import 'package:flutter/material.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/shared/constants.dart';
import 'package:my_app/shared/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  //const Register({ Key? key }) : super(key: key);

  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String username = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Color.fromRGBO(24,24,24, 2),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(24,24,24, 2),
        elevation: 0.0,
        title: Align(
        alignment: Alignment(0.66,2),
        child: Text(
                'diary'.toUpperCase(),
                style: GoogleFonts.gruppo(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: Colors.white), 
            label: Text('Sign in', style: TextStyle(color: Colors.white)),
            onPressed: () {
              widget.toggleView();
            },)
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Username'),
                validator: (val) => val!.isEmpty  ? 'Enter a valid username' : null,
                onChanged: (val) {
                  setState(() {
                    username = val + '@diary.com';
                  });
                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                validator: (val) => val!.length < 6 ? 'Enter a password of at least 6 characters' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                }
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.white, side: BorderSide(color: Color.fromRGBO(24,24,24, 2))),
                child: Text(
                  'Sign up',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.registerWithEmailAndPassword(username, password);
                    if (result == null) {
                      setState(() {
                        error = 'Please supply a valid username';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20.0),
              Text(error,style: TextStyle(color: Colors.red, fontSize: 14.0)),
            ],
          ),
        )
      ),
    );
  }
}