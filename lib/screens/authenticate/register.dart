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
        alignment: Alignment(0.1,2),
        child: Text(
                'diary'.toUpperCase(),
                style: GoogleFonts.gruppo(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Text('Sign Up', style: TextStyle(fontSize: 22, color: Colors.white)),
              SizedBox(height: 20),
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
                    error = '';
                  });
                }
              ),
              SizedBox(height: 5.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: Color.fromRGBO(24,24,24, 2))),
                child: Text(
                  'Done',
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
                        error = 'Username not valid or already taken';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text('Already have an account?', style: TextStyle(fontSize: 13, color: Colors.white)),
              SizedBox(width: 10.0),
              TextButton(
                //icon: Icon(Icons.person, color: Colors.white), 
                child: Text('Login', style: TextStyle(color: Colors.black)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  widget.toggleView();
                },)
              ]),
              SizedBox(height: 20.0),
              Text(error,style: TextStyle(color: Colors.red, fontSize: 14.0)),
            ],
          ),
        )
      ),
    );
  }
}