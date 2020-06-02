import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Activities with ChangeNotifier {
  List _activites = [];
  bool isLoadingActivities = true;
  String token;
  Map allActivityDetails = {};

  bool get notLoadingActivities {
    return isLoadingActivities;
  }

  List get activities {
    return _activites;
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
        if(onValue.statusCode == 200){
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          _activites = dataOrders["results"];
          allActivityDetails = dataOrders;
          isLoadingActivities = false;
          notifyListeners();
        }
        else{
          _activites = [];
          allActivityDetails = {};
          isLoadingActivities = false;
          notifyListeners();
        }

      });
    }
  }

  addActivityFromPostRequest(newactivity){
    _activites.add(newactivity);
    notifyListeners();
  }
}
