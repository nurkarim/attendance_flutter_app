import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
class Network{
  final String _url = 'https://hrm.hsengineering-bd.com/api';
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;
  Dio dio = new Dio();
  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
  }

  authData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(Uri.parse(
        fullUrl),
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print(fullUrl);
    return await http.post(Uri.parse(
        fullUrl),
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  dioPost(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print(fullUrl);
    return await dio.post(fullUrl,
        data: data,
        options: Options(headers: _setHeaders()));
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print(fullUrl);
    return await http.get(
        Uri.parse(fullUrl),
        headers: _setHeaders()
    );
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

}