import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Activities with ChangeNotifier {
  List<dynamic> _activites = new List(100);
  bool isLoadingActivities = true;
  String token;
  Map allActivityDetails = {};

  bool get notLoadingActivities {
    return isLoadingActivities;
  }

  set loadingActivities(bool boolean) {
    isLoadingActivities = boolean;
  }

  List get getActivities {
    return _activites;
  }

  List activities(index) {  
    print(index);
    return _activites[index];
  }

  Map get detailsActivities {
    return allActivityDetails;
  }

  Future fetchAndSetMyActivities(myToken, schedule_id) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.myActivities + schedule_id.toString() + "/activities/";
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          allActivityDetails = dataOrders;
          _activites[50] = dataOrders["results"];
          isLoadingActivities = false;
          notifyListeners();
        } else {
          _activites = [];
          allActivityDetails = {};
          isLoadingActivities = false;
          notifyListeners();
        }
      });
    }
    // fetchAndSetPrev(49, -1, myToken, schedule_id);
    // fetchAndSetNext(51, 1, myToken, schedule_id);
  }

  Future fetchAndSetNext(id, offset, myToken, schedule_id) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.myActivities +
          schedule_id.toString() +
          "/activities/?offset=" +
          offset.toString();
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          allActivityDetails = dataOrders;
          _activites[id] = dataOrders["results"];
          isLoadingActivities = false;
          notifyListeners();
        } else {
          _activites = [];
          allActivityDetails = {};
          isLoadingActivities = false;
          notifyListeners();
        }
      });
    }
  }

  Future fetchAndSetPrev(id, offset, myToken, schedule_id) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.myActivities +
          schedule_id.toString() +
          "/activities/?offset=" +
          offset.toString();
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          allActivityDetails = dataOrders;
          _activites[id] = dataOrders["results"];
          isLoadingActivities = false;
          notifyListeners();
        } else {
          _activites = [];
          allActivityDetails = {};
          isLoadingActivities = false;
          notifyListeners();
        }
      });
    }
  }

  // addActivityFromPostRequest(newactivity) {
  //   _activites.add(newactivity);
  //   notifyListeners();
  // }

  removeAllDataOfProvider() {
    _activites = [];
    allActivityDetails = {};
    loadingActivities = true;
  }
}
