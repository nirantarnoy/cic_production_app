import 'dart:async';
import 'dart:convert';

import 'package:cic_production_pi/models/User.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserData with ChangeNotifier {
  final String url_to_login =
      "http://app.cic-production-wip.net/api/authen/login";
  final String url_to_profile = "http://cic-support.net:1223/api/user/profile";

  late User _authenticatedUser;
  late User _emptyauthenicatedUser;
  late Timer _authTimer;

  // List<User> _user;
  // List<User> _userlogin;
  // List<User> get listuser => _user;
  // List<User> get listuserlogin => _userlogin;
  bool _isLoading = false;
  bool _isauthenuser = false;

  late String _username_display = '';
  String get username_display => _username_display;

  late String _team_display = '';
  String get team_display => _team_display;

  late String _team_safety_display = '';
  String get team_safety_display => _team_safety_display;

  late String _photo_display = '';
  String get photo_display => _photo_display;

  late String _section_display = '';
  String get section_display => _section_display;

  late List<User> _userdata;
  List<User> get userdata => _userdata;

  set userdata(List<User> val) {
    _userdata = val;
  }

  set team_display(String val) {
    _team_display = val;
  }

  set team_safety_display(String val) {
    _team_safety_display = val;
  }

  set photo_display(String val) {
    _photo_display = val;
  }

  set username_display(String val) {
    _username_display = val;
  }

  set section_display(String val) {
    _section_display = val;
  }

  Future<dynamic> login(String username, String pwd) async {
    final Map<String, dynamic> loginData = {
      'username': username,
      'password': pwd,
    };

    print("data login is ${loginData}");

    try {
      http.Response response;
      response = await http.post(Uri.parse(url_to_login),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData));

      if (response.statusCode == 200) {
        Map<String, dynamic> res = json.decode(response.body);
        List<User> data = [];

        if (res == null) {
          notifyListeners();
          return false;
        }
        print('res data login is ${res}');
        for (var i = 0; i < res['data'].length; i++) {
          final User user = User(
            id: res['data'][i]['id'].toString(),
            person_no: res['data'][i]['person_no'].toString(),
            person_name: res['data'][i]['person_name'].toString(),
            emp_shift_id: res['data'][i]['emp_shift_id'].toString(),
            emp_work_shift_id: res['data'][i]['emp_work_shift_id'].toString(),
            emp_work_shift_name:
                res['data'][i]['emp_work_shift_name'].toString(),
          );

          data.add(user);
        }

        userdata = data;

        final DateTime now = DateTime.now();
        final DateTime expiryTime = now.add(Duration(seconds: 160000));
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('user_id', res['data'][0]['id'].toString());
        prefs.setString('user_name', res['data'][0]['person_name'].toString());
        prefs.setString('expiryTime', expiryTime.toIso8601String());
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  String getCurrenUserName() {
    String c_username = '';
    if (username_display != '') {
      c_username = username_display;
    }
    return c_username;
  }

  String getCurrenUserPhoto() {
    String c_photo = '';
    if (photo_display != '') {
      c_photo = photo_display;
    }
    return c_photo;
  }

  String getCurrenUserSection() {
    String c_section_code = '';
    if (section_display != '') {
      c_section_code = section_display;
    }
    return c_section_code;
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //   final String token = prefs.getString('token');
    final String? expiryTimeString = prefs.getString('expiryTime').toString();

    final DateTime now = DateTime.now();
    final parsedExpiryTime = DateTime.parse(expiryTimeString!);
    if (parsedExpiryTime.isBefore(now)) {
      // _authenticatedUser = _emptyauthenicatedUser;
      notifyListeners();
      return;
    }
    final String? emp_id = prefs.getString('emp_id').toString();
    final String? userId = prefs.getString('user_id').toString();
    final String? adUsername = prefs.getString('dns_user').toString();

    final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
    _authenticatedUser = User(
      id: userId!,
      person_no: '',
      person_name: '',
      emp_shift_id: '',
      emp_work_shift_id: '',
      emp_work_shift_name: '',
    );

    _isauthenuser = true;
    setAuthTimeout(tokenLifespan);
    notifyListeners();
  }

  Future<Map<String, dynamic>> logout() async {
    //_authenticatedUser = _emptyauthenicatedUser;
    _isauthenuser = false;
    _authTimer.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // prefs.remove('token');
    // prefs.remove('emp_id');

    // prefs.remove('username');
    // prefs.remove('userId');
    // prefs.remove('studentId');

    _isLoading = false;
    return {'success': true};
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}
