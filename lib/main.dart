import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_app/screens/wrapper.dart';
import 'package:my_app/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:my_app/models/usermodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      initialData: null,
      value: AuthService().user,
      child: ScreenUtilInit(
          designSize: ScreenUtil.defaultSize,
          builder: (context,data) => MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: new ThemeData(
                    scaffoldBackgroundColor: Color.fromRGBO(0, 0, 0, 1)),
                home: Wrapper(),
              )),
    );
  }
}

