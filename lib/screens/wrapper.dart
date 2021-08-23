import 'package:my_app/screens/authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/usermodel.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel?>(context);
    
    if (user == null) {
      return Authenticate();
    } else {
      return HomeScreen();
    }
  }
}