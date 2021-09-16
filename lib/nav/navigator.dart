import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs_attendance/auth/login.dart';
import 'package:hs_attendance/pages/clock_in.dart';
import 'package:hs_attendance/pages/clock_out.dart';
import 'package:hs_attendance/pages/dashboard.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:hs_attendance/pages/leave_apply.dart';
import 'package:hs_attendance/pages/my_profile.dart';
import 'package:hs_attendance/pages/password_change.dart';
import 'package:hs_attendance/pages/time_sheet_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String name = "";
  String mobile = "";
  String _networkImage="https://hrm.itadventurebd.com/public/images/profile-picture.png";
  void initState() {
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user').toString());
    var token = localStorage.getString('token');
    var image_get = localStorage.getString('image');
    if (user != null) {
      setState(() {
        name = user['name'];
        mobile = user['mobile_no'];
        _networkImage = image_get.toString();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 200,
              // child: DrawerHeader(
              //    child: Image.asset('image/toi.png'),
              //    decoration: BoxDecoration(
              //      color: Colors.white,
              //      // image: DecorationImage(
              //      //     // fit: BoxFit.fill,
              //      //     image: AssetImage('image/toi.png'),
              //      // )
              //    ),
              //  ),
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blueAccent, Colors.lightBlueAccent]
                )),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage:   NetworkImage('$_networkImage'),
                        radius: 50.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18.0),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '$mobile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12.0),
                          ),
                        ],
                      )
                    ]),
              )),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Dashboard'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (__) => Dashboard()))
            },
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text('Clock in'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (__) => ClockIn()))
            },
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text('Clock out'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (__) => ClockOut()))
            },
          ),
          ListTile(
            leading: Icon(Icons.document_scanner_outlined),
            title: Text('Leave'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (__) => LeaveHistory()))
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today_rounded),
            title: Text('Time sheet'),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (__) => TimeSheetHistory()))
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (__) => MyProfile()))
            },
          ),
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('Password Change'),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (__) => PasswordChange()))
            },
          ),

          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Logout'),
            onTap: () async {
              SharedPreferences localStorage =
              await SharedPreferences.getInstance();
              http.Response response = await Network().getData('/logout');
              // print(response.statusCode);
              if (response.statusCode == 200) {
                var body = json.decode(response.body);
                if (body['success']) {
                  SharedPreferences localStorage =
                  await SharedPreferences.getInstance();
                  localStorage.remove('user');
                  localStorage.remove('token');
                  localStorage.remove('image');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Exit'),
            onTap: () => {
              if (Platform.isAndroid) {SystemNavigator.pop()} else {exit(0)}
            },
          ),
        ],
      ),
    );
  }
}



