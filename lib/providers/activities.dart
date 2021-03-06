import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Activities with ChangeNotifier {
  List<dynamic> _activites = new List(40);
  List<dynamic> tempListBeforeLoad = new List(22);
  var middle = 20;
  bool isLoadingActivities = true;
  bool isLoadingPrevOrNext = false;
  int fetchCallCountInitialBuild = 0;
  String token;
  String scheduleId;
  Map allActivityDetails = {};

  bool get notLoadingActivities {
    return isLoadingActivities;
  }

  set loadingActivities(bool boolean) {
    isLoadingActivities = boolean;
  }

  List get getActivities {
    if (_activites[middle] == null) {
      tempListBeforeLoad[middle - 1] = [];
      tempListBeforeLoad[middle] = [];
      tempListBeforeLoad[middle + 1] = [];
      return tempListBeforeLoad;
    }
    return _activites;
  }

  List activities(index) {
    if (index == middle || index == middle - 1 || index == middle + 1)
      fetchCallCountInitialBuild++;
    if (fetchCallCountInitialBuild >= 3) {
      fetchCallCountInitialBuild = 2;
      return _activites[index];
    }
    var offset;
    if (index != middle) {
      offset = index - middle;
      isLoadingPrevOrNext = true;
      fetchAndSetNextOrPrev(index, offset, token, scheduleId);
    }
    return _activites[index];
  }

  Map get detailsActivities {
    return allActivityDetails;
  }

  Future fetchAndSetMyActivities(myToken, schedule_id) async {
    token = myToken;
    if (token != null && token != "null") {
      scheduleId = schedule_id.toString();
      String url = Api.myActivities + schedule_id.toString() + "/activities/";
      http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          allActivityDetails = dataOrders;
          _activites[middle] = dataOrders["results"];

          ///middle
          isLoadingActivities = false;
          notifyListeners();
          fetchAndSetNextOrPrev(middle + 1, 1, myToken, schedule_id);
          fetchAndSetNextOrPrev(middle - 1, -1, myToken, schedule_id);
        } else {
          _activites = [];
          allActivityDetails = {};
          isLoadingActivities = false;
          notifyListeners();
        }
      });
    }
  }

  Future fetchAndSetNextOrPrev(id, offset, myToken, schedule_id) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.myActivities +
          schedule_id.toString() +
          "/activities/?offset=" +
          offset.toString();
      http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          allActivityDetails = dataOrders;
          _activites[id] = dataOrders["results"];
          isLoadingPrevOrNext = false;

          notifyListeners();
        } else {
          _activites = [];
          allActivityDetails = {};
          isLoadingPrevOrNext = false;
          notifyListeners();
        }
      });
    }
  }

  Future removeActivity(schedule_id, id, i, token) {
    String url = Api.myActivities +
        schedule_id.toString() +
        "/activities/" +
        id.toString() +
        "/";
    http.delete(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );

    //Todo send index

    _activites[middle].removeAt(i);
    _activites[middle].add({});
    _activites[middle].removeLast();
    _activites[middle].insert(0, {});
    _activites[middle].removeAt(0);
    
    _activites[middle] = sortForActivities(_activites[middle]);
    notifyListeners();
  }

  sortForActivities(list) {
    if (list == null || list.length == 0) return;
    int n = list.length;
    int i, step;
    for (step = 0; step < n; step++) {
      for (i = 0; i < n - step - 1; i++) {
        if (DateTime.parse(list[i]["activity"]["start_times"][0]).compareTo(
                DateTime.parse(list[i + 1]["activity"]["start_times"][0])) >
            0) {
          var temp = list[i];
          list[i] = list[i + 1];
          list[i + 1] = temp;
        }
      }
    }
    return list;
  }

  addActivityFromPostRequest(newactivity) {
    var date = DateTime.now();
    var date2 = date.add(Duration(
        days: 7 - date.weekday,
        hours: 23 - date.hour,
        minutes: 59 - date.minute));
    var newActivityDate =
        DateTime.parse(newactivity["activity"]["start_times"][0].toString());
    int difference = newActivityDate.difference(date2).inDays;

    if (difference > 0) {
      difference = (difference ~/ 7);
      if (_activites[difference + middle + 1] == null)
        _activites[difference + middle + 1] = [];
      _activites[difference + middle + 1].insert(0, newactivity);
    } else {
      difference = (difference ~/ 7);
      if (_activites[difference + middle] == null)
        _activites[difference + middle] = [];
      _activites[difference + middle].insert(0, newactivity);
    }
    notifyListeners();
  }

  removeAllDataOfProvider() {
    _activites = [];
    _activites = new List(40);
    allActivityDetails = {};
    loadingActivities = true;
  }
}
