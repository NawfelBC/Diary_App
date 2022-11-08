import 'package:flutter/material.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/shared/constants.dart';
import 'package:my_app/shared/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  //const SignIn({ Key? key }) : super(key: key);
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

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
              Text('Login', style: TextStyle(fontSize: 22, color: Colors.white)),
              SizedBox(height: 20),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Username'),
                validator: (val) => val!.isEmpty  ? 'Enter a valid username' : null,
                onChanged: (val) {
                  setState(() {
                    username = val+'@diary.com';
                  });
                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                validator: (val) => val!.isEmpty ? 'Enter a password' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
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
                    dynamic result = await _auth.signInWithEmailAndPassword(username, password);
                    if (result == null) {
                      setState(() {
                        error = 'Could not sign in with those credentials';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20.0),
              error != '' ? Text(error,style: TextStyle(color: Colors.red, fontSize: 14.0)) :
              SizedBox(height: 5.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text('Don’t have an account yet?', style: TextStyle(fontSize: 13, color: Colors.white)),
              SizedBox(width: 10.0),
              TextButton(
                //icon: Icon(Icons.person, color: Colors.white), 
                child: Text('Sign up', style: TextStyle(color: Colors.black)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () {
                  widget.toggleView();
                },)
              ]),
            ],
          ),
        )
      ),
    );
  }
}