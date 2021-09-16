import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hs_attendance/network_utils/api.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  var image;
  File? imagePicked;
  PickedFile? pickedImage;
  ImagePicker picker = ImagePicker();
  Dio dio = new Dio();
  bool showSpiner = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message){
    try {
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
              disabledTextColor: Colors.grey,
            ),
          )
      );
    } on Exception catch (e, s) {
      print(s);
    }
  }
  _getImageFromGallery() async {
    var imageq = await picker.pickImage(source: ImageSource.gallery);
    setState(() => image = imageq);
  }

  String name = "";
  String mobile = "";
  String email = '';
  var id;
  String address = '';
  String department = '';
  String designation = '';
  String _networkImage =
      "https://hrm.itadventurebd.com/public/images/profile-picture.png";
  var getData;

  void initState() {
    getProfileData();
    _loadUserData();
    super.initState();
  }

  Future<void> getProfileData() async {
    try {
      setState(() {
        showSpiner = true;
      });
      http.Response response = await Network().getData('/my_profile');
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        var value = body['data'];
        setState(() {
          _networkImage = value['image'];
          email = value['email'];
          mobile = value['phone'];
          address = value['address'];
          department = value['department'];
          designation = value['designation'];
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
        getData = image_get.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpiner,
        child: ListView(children: [
          Container(
            height: size.height * .3,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blueAccent, Colors.lightBlueAccent]
                )
            ),
            child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Colors.redAccent,
                        backgroundImage: NetworkImage('$_networkImage'),
                        child: FlatButton(
                          onPressed: () async {
                            // await _getImageFromGallery();
                            pickedImage = await ImagePicker()
                                .getImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              setState(() {
                                imagePicked = File(pickedImage!.path);
                              });
                            }
                            try {
                              String fileName = imagePicked!.path.split('/').last;
                              var extention = fileName.split('.').last;
                              FormData fromdata = new FormData.fromMap({
                                'image': await MultipartFile.fromFile(
                                    imagePicked!.path,
                                    filename: fileName,
                                    contentType: MediaType('image', 'png')),
                                'type': 'image/png'
                              });
                              setState(() {
                                showSpiner = true;
                              });
                              Response response = await Network().dioPost(
                                  fromdata, '/change_image?image=$fileName');
                              print(response.statusCode);
                              if (response.statusCode == 200) {
                                var body = response.data;
                                var value = body['data'];
                                _showMessageInScaffold(body['message']);
                                setState(() {
                                  _networkImage = value['image'];
                                  showSpiner = false;
                                });
                                // SharedPreferences localStorage = await SharedPreferences.getInstance();
                                // localStorage.setString('image', value['image']);

                              }
                              setState(() {
                                showSpiner = false;
                              });
                              _showMessageInScaffold('Profile image upload failed');
                            } catch (ex) {
                              setState(() {
                                showSpiner = false;
                              });
                              _showMessageInScaffold('Something was wrong');
                            }
                          },
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20.0,
                              child: Icon(
                                Icons.camera_alt,
                                size: 30.0,
                                color: Color(0xFF404040),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("$name",
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.white,
                        )),
                    ],
                  ),
                )),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            width: double.infinity,
            transform: Matrix4.translationValues(0.0, -10.0, 0.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.white, Colors.white60]
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.mobile_friendly,size: 30,),
                              Text(' $mobile', style: TextStyle(color: Colors.black,fontSize: 16),)
                            ],
                          ),
                        ),
                      ), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined,size: 30,),
                              Text(' $email', style: TextStyle(color: Colors.black,fontSize: 16),)
                            ],
                          ),
                        ),
                      ), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user,size: 30,),
                              Text(' $department', style: TextStyle(color: Colors.black,fontSize: 16),)
                            ],
                          ),
                        ),
                      ), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.account_circle_outlined,size: 30,),
                              Text(' $designation', style: TextStyle(color: Colors.black,fontSize: 16),)
                            ],
                          ),
                        ),
                      ), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                    child: Container(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.map_outlined,size: 30,),
                              Text(' $address', style: TextStyle(color: Colors.black,fontSize: 16),)
                            ],
                          ),
                        ),
                      ), decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),border: Border.all(width: 1.0, color: Colors.black12)),
                    ),
                  )
                ]
            ),
          )
        ]),
      ),
    );
  }
}
