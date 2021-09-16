import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hs_attendance/pages/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpiner = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _formKey,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpiner,
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              height: size.height * .3,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Color(0xFF262AAA),
                  Color(0xFF262AAA),
                  Color(0xFF262AAA)
                ],
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  new Image.asset(
                    'assets/image/logo.png',
                    height: 90,
                    width: 90,
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // Text(
                  //   "HS Login",
                  //   style: TextStyle(color: Colors.white, fontSize: 18),
                  // ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              height: 20,
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Mobile Number",
                    hintText: 'Mobile number',
                    hintStyle: TextStyle(
                      color: Color(0xFF9b9b9b),
                      fontSize: 15,
                      fontWeight: FontWeight.normal)),

              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                    hintText: "Enter secure password"),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.black,
              ),
              onPressed: () {},
              child: Text('Forgot Password?'),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              width: 250,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue, width: 2.0)))),
                child: Text(
                    _isLoading? 'Loging...' : 'Login',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    showSpiner = true;
                  });
                  var data = {
                    'mobile_no': nameController.text,
                    'password': passwordController.text
                  };
                  // String webUrl =
                  //     "https://hrm.hsengineering-bd.com/api/login?mobile_no=01687032498&password=01687032498";
                  // var url = Uri.parse(webUrl);
                  try {
                    //http.Response response = await http.post(url);
                    http.Response response =
                        await Network().authData(data, '/login');
                    if (response.statusCode == 200) {
                      var body = jsonDecode(response.body);
                      if (body['success']) {
                        var token = body['data'];
                        SharedPreferences localStorage = await SharedPreferences.getInstance();
                        localStorage.setString('token', token['token']);
                        localStorage.setString('user', jsonEncode(token['user']));
                        localStorage.setString('image', token['image']);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Login Success"),
                        ));
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => Dashboard()),
                        );

                        setState(() {
                          _isLoading = false;
                          showSpiner = false;
                        });

                      } else {
                        setState(() {
                          _isLoading = false;
                          showSpiner = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Login Failed"),
                        ));
                      }
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Login Failed.Try again later."),
                      ));
                    }
                    setState(() {
                      _isLoading = false;
                      showSpiner = false;
                    });
                  }catch(exp){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Login Failed"),
                      action: SnackBarAction(label: 'Close', onPressed:() {
                        // Some code to undo the change!
                      }),
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
