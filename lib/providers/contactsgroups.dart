import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ContactsGroups with ChangeNotifier {
  List _contacts = [];
  bool isLoadingContacts = true;
  String token;
  Map allContactsDetails = {};

  bool get notLoadingContacts {
    return isLoadingContacts;
  }

  List get contacts {
    return _contacts;
  }

  Map get detailsContacts {
    return allContactsDetails;
  }

  Future fetchAndSetMyContacts(myToken) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.userslistAndSignUp;
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          _contacts = dataOrders["results"];
          allContactsDetails = dataOrders;
          isLoadingContacts = false;
          notifyListeners();
        } else {
          _contacts = [];
          allContactsDetails = {};
          isLoadingContacts = false;
          notifyListeners();
        }
      });
    }
  }


  // addActivityFromPostRequest(newactivity) {
  //   _contacts.add(newactivity);
  //   notifyListeners();
  // }
  
}