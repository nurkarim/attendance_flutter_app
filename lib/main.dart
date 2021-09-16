// @dart=2.9
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:hs_attendance/auth/login.dart';
import 'package:hs_attendance/pages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}
// Using command line
//
// flutter run --no-sound-null-safety
// or to be specific (say in chrome)
//
// flutter run -d chrome --no-sound-null-safety
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen(
        splash: new Image.asset('assets/image/logo.png',height: 200,width: 200),
        nextScreen: CheckAuth(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.blue,
        duration: 3000,
      ),
    );
  }
}

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  void _checkIfLoggedIn() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if(token != null){
      setState(() {
        isAuth = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth) {
      child = Dashboard();
    } else {
      child = Login();
    }
    return Scaffold(
      body: child,
    );
  }
}


