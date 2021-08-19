import 'package:flutter/material.dart';
import 'package:my_app/screens/home/home_screen.dart';
import 'package:my_app/screens/home/profile_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool showFeed = true;
  void toggleView() {
    setState(() {
      showFeed = !showFeed;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showFeed) {
      return HomeScreen(toggleView: toggleView);
    } else {
      return ProfileScreen(toggleView: toggleView);
    }
  }
}