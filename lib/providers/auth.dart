import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:youcan/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiredate;
  String? _userId;
  Timer? _authTimer;

  //to access _token we get it without the private _
  String? get token {
    if (_expiredate != null &&
        _expiredate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return _token != null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String pass, String urlSegment) async {
    final url = Uri.parse(
        //Todo add your API KEY
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=");

    try {
      //Send a request to signIn or signUp
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': pass,
            'returnSecureToken': true,
          }));
      //get data back
      final resData = json.decode(res.body);
      //for catching error
      if (resData['error'] != null) {
        //HttpException is a class to return the message
        throw HttpException(resData['error']['message']);
      }
      if (urlSegment == "signInWithPassword") {
        _token = resData['idToken'];
        _userId = resData['localId'];
        _expiredate = DateTime.now()
            .add(Duration(seconds: int.parse(resData['expiresIn'])));
        notifyListeners(); //any time values is changes

        //Simple store of data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final autoData = json.encode({
          'token': _token,
          'userId': _userId,
          '_expiredate': _expiredate!.toIso8601String()
        });
        prefs.setString('autoData', autoData);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String? email, String? pass) async {
    return _authenticate(email!, pass!, "signUp");
  }

  Future<void> logIn(String? email, String? pass) async {
    return _authenticate(email!, pass!, "signInWithPassword");
  }

  //Called in hot restart
  Future<bool> autoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    //If we signed In before and store data in prefs
    if (prefs.containsKey('autoData')) {
      final autoData =
          json.decode(prefs.getString('autoData') as String) as Map;
      final DateTime expDate =
          DateTime.parse(autoData['_expiredate'] as String);
      if (expDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = autoData['token'] as String?;
      _userId = autoData['userId'] as String?;
      _expiredate = expDate;
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void logout() async {
    _token = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    _authTimer = null;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
