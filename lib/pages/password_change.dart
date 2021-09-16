import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key}) : super(key: key);

  @override
  _PasswordChangeState createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  bool showSpiner = false;
  String oldpass = '';
  String newpass = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
        title: Text('Password Change', textAlign: TextAlign.center),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpiner,
        child: ListView(children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            height: size.height * .2,
            transform: Matrix4.translationValues(0.0, -10.0, 0.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60))),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: nameController,
              cursorColor: Color(0xFF9b9b9b),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                oldpass = value;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Current Password",
                  hintText: 'Current Password',
                  hintStyle: TextStyle(
                      color: Color(0xFF9b9b9b),
                      fontSize: 15,
                      fontWeight: FontWeight.normal)),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: passwordController,
              cursorColor: Color(0xFF9b9b9b),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                newpass = value;
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "New Password",
                  hintText: 'New Password',
                  hintStyle: TextStyle(
                      color: Color(0xFF9b9b9b),
                      fontSize: 15,
                      fontWeight: FontWeight.normal)),
            ),
          ),
          Container(
            height: 50,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            width: 250,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blue, width: 2.0)))),
              child: Text(
                'Password Change',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                setState(() {
                  showSpiner = true;
                });
                var data = {'current_password': oldpass, 'password': newpass};

                try {
                  //http.Response response = await http.post(url);
                  http.Response response =
                      await Network().postData(data, '/change_password');
                  if (response.statusCode == 200) {
                    var body = jsonDecode(response.body);
                    if (body['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Password Change Success"),
                      ));
                    }
                  }
                  print(response.statusCode);
                  setState(() {
                    showSpiner = false;
                  });
                } catch (exp) {
                  setState(() {
                    showSpiner = false;
                  });
                }
              },
            ),
          )
        ]),
      ),
    );
  }
}
