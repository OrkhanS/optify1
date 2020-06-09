import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:optifyapp/providers/activities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';
import '../models/api.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Map user = {};
  bool isLoadingUser = true;

  String myTokenFromStorage;
  String myScheduleidFromStorage;
  String myUseridFromStorage;


  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;    
      myTokenFromStorage = extractedUserData["token"];
      myUseridFromStorage = extractedUserData['user_id'].toString();
      myScheduleidFromStorage = extractedUserData['schedule_id'].toString();
  }

  String get myToken{
    return myTokenFromStorage;
  }

  String get myScheduleId{
    return myScheduleidFromStorage;
  }

  String get myUserId{
    return myUseridFromStorage;
  }

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  set token(String tokenlox) {
    _token = tokenlox;
  }

  String get userId {
    return _userId;
  }

  Map get userdetail {
    return user;
  }

  bool get isNotLoading {
    return isLoadingUser;
  }

  Future fetchAndSetUserDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('userData')) {
//       return false;
//     }
//     final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

//     const url = Api.address + "api/users/me/";
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           HttpHeaders.CONTENT_TYPE: "application/json",
//           "Authorization": "Token " + extractedUserData['token'],
//         },
//       ).then((response) {
//         final dataOrders = json.decode(response.body) as Map<String, dynamic>;
//         user = dataOrders;
//         isLoadingUser = false;
//         notifyListeners();
//       });
//     } catch (e) {
//       return;
//     }
//   }

//   Future<void> _authenticate(String email, String password, String urlSegment) async {
// //    final url =
// //        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyC13spCwP_f_SalxEbkB-wjedoF8iYENlQ';
//     const url = "http://briddgy.herokuapp.com/api/auth/";
//     try {
//       final response = await http.post(
//         url,
//         body: json.encode(
//           {
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           },
//         ),
//       );
//       final responseData = json.decode(response.body);
//       if (responseData['error'] != null) {
//         throw HttpException(responseData['error']['message']);
//       }
//       _token = responseData['idToken'];
//       _userId = responseData['localId'];
//       _expiryDate = DateTime.now().add(
//         Duration(
//           seconds: int.parse(
//             responseData['expiresIn'],
//           ),
//         ),
//       );
// //      _autoLogout();
//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       final userData = json.encode(
//         {
//           'token': _token,
//           'userId': _userId,
//           'expiryDate': _expiryDate.toIso8601String(),
//         },
//       );
//       prefs.setString('userData', userData);
//     } catch (error) {
//       throw error;
//     }
  }

  Future<void> signup(String email, String password, String firstname, String lastname
//      , String deviceID todo fix
      ) async {
    //return _authenticate(email, password, 'signupNewUser');
    const url = Api.userslistAndSignUp;
    try {
      final response = await http.post(url,
          headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
          body: json.encode({
            "username": email, //todo fix
            "password": password,
            "deviceToken": '', //todo orxan
            "first_name": firstname,
            "last_name": lastname,
            "email": email,
          }));
      final responseData = json.decode(response.body);
//      final responseData = response.body;
      print("Token: $responseData");
//      if (responseData['error'] != null) {
//        throw HttpException(responseData['error']['message']);
//      }
      _token = responseData["token"];
//      _token = responseData['idToken'];
//      _userId = responseData['localId'];
//      _expiryDate = DateTime.now().add(
//        Duration(
//          seconds: int.parse(
//            responseData['expiresIn'],
//          ),
//        ),
//      );
//      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
//          'userId': _userId,
//          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    //return _authenticate(email, password, 'verifyPassword');
  }

  Future<void> login(String email, String password
//      , String deviceID todo fix
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    prefs.commit();
    const url = Api.login;
    try {
      final response = await http.post(url,
          headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
          body: json.encode({
            "username": email,
            "password": password,
            "deviceToken": '', //todo orxan
          }));

      final responseData = json.decode(response.body);
      _token = responseData["token"];
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'user_id': responseData["user_id"],
          "schedule_id": responseData["schedule_id"]
        },
      );

      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> getScheduleID(String token) async {
    const url = Api.myScheduleInfo;
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.CONTENT_TYPE: "application/json", "Authorization": "Token " + token},
      );

      final responseData = json.decode(response.body);
      String schedule_id = responseData["id"].toString();
      final prefs = await SharedPreferences.getInstance();
      final scheduleData = json.encode(
        {
          'schedule_id': schedule_id.toString(),
        },
      );

      prefs.setString('scheduleData', scheduleData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
//    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
//
//    if (expiryDate.isBefore(DateTime.now())) {
//      return false;
//    }
    _token = extractedUserData['token'];
    myTokenFromStorage = extractedUserData["token"];
    myUseridFromStorage = extractedUserData['user_id'].toString();
    myScheduleidFromStorage = extractedUserData['schedule_id'].toString();

//    _userId = extractedUserData['userId'];
//    _expiryDate = expiryDate;
    notifyListeners();
//    _autoLogout();
    return true;
  }

  Future<void> logout(context) async {
    print(_token);
    const url = Api.login;
    http.patch(url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + _token,
        },
        body: json.encode({"token": _token}));

    _token = null;
    Navigator.of(context).pop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    prefs.commit();
    prefs.clear();
    Provider.of<Activities>(context).removeAllDataOfProvider();
    Provider.of<Activities>(context).removeAllDataOfProvider();
    
    notifyListeners();
  }

//  void _autoLogout() {
//    if (_authTimer != null) {
//      _authTimer.cancel();
//    }
//    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
//    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
//  }
}
