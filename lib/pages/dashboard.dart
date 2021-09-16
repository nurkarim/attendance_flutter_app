import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hs_attendance/nav/navigator.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String name = "";
  String mobile = "";
  String imageName =
      "https://hrm.itadventurebd.com/public/images/profile-picture.png";

  //Declare a GlobalKey
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpiner = false;
  String total_leave = "0";
  String total_present = "0";
  String total_late = "0";
  String total_absent = "0";
  String date_range = "";

  @override
  void initState() {
    _loadUserData();
    getProfileData();
    getcurrentlocation();
    getProfile();
    super.initState();
  }

  Future<void> getProfile() async {
    try {
      setState(() {
        showSpiner = true;
      });
      http.Response response = await Network().getData('/my_profile');
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var value = body['data'];
        setState(() {
          imageName = value['image'];
          mobile = value['phone'];
          showSpiner = false;
        });
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('image', value['image']);
      }
      setState(() {
        showSpiner = false;
      });
    } catch (ex) {
      setState(() {
        showSpiner = false;
      });
    }
  }

  Future<void> getcurrentlocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Turn on your location and refresh this page"),
      ));
    }
  }

  Future<void> getProfileData() async {
    try {
      setState(() {
        showSpiner = true;
      });
      http.Response response = await Network().getData('/home');
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var value = body['data'];
        print(value);
        setState(() {
          showSpiner = false;
          total_leave = value['total_leave'].toString();
          total_present = value['total_present_day'].toString();
          total_late = value['total_late'].toString();
          total_absent = value['total_absent'].toString();
          date_range = value['date_time'].toString();
        });
      }
      setState(() {
        showSpiner = false;
      });
    } catch (ex) {
      print(ex);
      setState(() {
        showSpiner = false;
      });
    }
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
        imageName = image_get.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .3,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blueAccent, Colors.lightBlueAccent])),
            child: AppBar(
              title: Text(
                "Dashboard",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF1FA4EC),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.notifications_none),
                  onPressed: () {},
                )
              ],
            ),
          ),
          Container(
            height: 100,
            margin: EdgeInsets.only(top: 70),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    // backgroundImage: AssetImage('assets/image/avatar.jpeg'),
                    backgroundImage: NetworkImage('$imageName'),
                    radius: 40.0,
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
                            fontSize: 15.0),
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
                  ),
                ]),
          ),

          Container(
            margin: EdgeInsets.only(top: 200.0),
            padding: EdgeInsets.all(10.0),
            child:
            Text(
              'Date: $date_range',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 15.0),
            )
            ,
          ),
          Container(
            margin: EdgeInsets.only(top: 230.0),
            child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(3.0),
                children: <Widget>[
                  makeDashboardItem(
                      "Total Absent", Icons.book, '$total_absent'),
                  makeDashboardItem(
                      "Total Present", Icons.book, '$total_present'),
                  makeDashboardItem("Total Late", Icons.book, '$total_late'),
                  makeDashboardItem("Total Leave", Icons.book, '$total_leave'),
                ]),
          )
        ],
      ),
    );
  }
}

Card makeDashboardItem(String title, IconData icon, String value) {
  return Card(
      elevation: 2.0,
      margin: new EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1.0)),
        child: new InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              SizedBox(height: 50.0),
              Center(
                  child: new Text(
                '$value',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              )),
              SizedBox(height: 20.0),
              new Center(
                child:
                    new Text(title, style: new TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ));
}
