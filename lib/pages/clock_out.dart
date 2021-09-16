import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:http/http.dart' as http;

class ClockOut extends StatefulWidget {
  const ClockOut({Key? key}) : super(key: key);

  @override
  _ClockInState createState() => _ClockInState();
}

class _ClockInState extends State<ClockOut> with SingleTickerProviderStateMixin {
  var controller;
  bool showSpiner = false;
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message){
    try {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState!.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label:'Click',
              onPressed: () {
                print('Action is clicked');
              },
              textColor: Colors.white,
              disabledTextColor: Colors.blueGrey,
            ),
          )
      );
    } on Exception catch (e, s) {
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Clock Out',textAlign: TextAlign.center),
      ),
      body:
      ModalProgressHUD(
      inAsyncCall: showSpiner,
    child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        color: Colors.white,
        child: GestureDetector(
          onTapDown: (_) => controller.forward(),
          onTapUp: (_) async {
            if (controller.status == AnimationStatus.completed) {
              try {
                setState(() {
                  showSpiner = true;
                });
                http.Response response = await Network().getData(
                    '/clock_out');
                print(response.statusCode);
                if (response.statusCode == 200) {
                  var body = json.decode(response.body);
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: Text(body['message']),
                  //   backgroundColor: Colors.blueGrey,
                  // ));
                  _showMessageInScaffold(body['message']);
                  setState(() {
                    showSpiner = false;
                  });
                } else {
                  var body = json.decode(response.body);
                  _showMessageInScaffold(body['data']['error']);
                  setState(() {
                    showSpiner = false;
                  });
                }
              }catch(ex){
                _showMessageInScaffold('Sorry!something was wrong.');
              }
              controller.value = 0.0;
            }
            if (controller.status == AnimationStatus.forward) {
              controller.reverse();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  semanticsLabel: 'Tap here',
                  strokeWidth: 10.0,
                  value: controller.value,
                  backgroundColor: Color(0xFF55A1CD),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                ),
              ),
              Text('Tap to Hold',style: TextStyle(fontSize: 15,color: Colors.blue),)
            ],
          ),
        ),
      ) ,
    )
    );
  }
}

