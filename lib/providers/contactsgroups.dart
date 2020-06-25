import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ContactsGroups with ChangeNotifier {
  List _contacts = [];
  bool isLoadingContacts = true;
  String token;
  Map allContactsDetails = {};
  Map tempContactDetails = {};
  Map allGroupsDetails = {};
  List _groups = [];
  Map combinedList = {};
  bool isLoadingGroups = true;
  Map groupActivityDetails = {};
  List groupActivities = [];
  List activityMembers = [];

  set activityMemberList(List a){
    activityMembers = a;
    notifyListeners();
  }

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
      String url = Api.myContacts;
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
          combinedList["contacts"] = dataOrders;
          allContactsDetails = dataOrders;
          isLoadingContacts = false;
          notifyListeners();
        } else {
          _contacts = [];
          allContactsDetails = {};
          combinedList["contacts"] = {};
          isLoadingContacts = false;
          notifyListeners();
        }
      });
    }
  }

  removeContact(i) {
    _contacts.removeAt(i);
    notifyListeners();
  }

  Future requestContact(id, token) {
    String url = Api.myContacts;
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({"reciever": id}))
        .then((response) {
      if (response.statusCode == 200) {
        fetchAndSetMyContacts(token);
      }
    });
  }

  Future acceptContactRequest(i, token) {
    String url =
        Api.respondContactRequst + _contacts[i]["id"].toString() + "/respond/";
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({"response": "acc"}))
        .then((response) {
      if (response.statusCode == 200) {
        _contacts[i]["state"] = "acc";
        notifyListeners();
      }
    });
  }

  Future removeContactOrRequest(i, token) {
    String url = Api.removeContactRequst + _contacts[i]["id"].toString() + "/";
    http.delete(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );
    removeContact(i);
  }

  removeAllDataOfProvider() {
    _contacts = [];
    allContactsDetails = {};
    isLoadingContacts = true;
  }

  addContactFromPostRequest(newcontact) {
    _contacts.add(newcontact);
    notifyListeners();
  }

//-------------------------------------------------------------------------------------------------------------------------------------------
  Future fetchAndSetMyGroups(myToken) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.createGroupAndMyGroups;
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          _groups = dataOrders["results"];
          combinedList["groups"] = dataOrders;
          allGroupsDetails = dataOrders;
          isLoadingGroups = false;
          notifyListeners();
        } else {
          _groups = [];
          allGroupsDetails = {};
          combinedList["groups"] = {};
          isLoadingGroups = false;
          notifyListeners();
        }
      });
    }
  }

  Map get detailsGroup{
    return allGroupsDetails;
  }

  List get groups{
    return _groups;
  }

  Map get combinedLists{
    return combinedList;
  }

  get lengthLists{
    return combinedList["groups"]["results"].length+combinedList["contacts"]["results"].length;
  }

  Future fetchAndSetGroupActivities(myToken, id) async {
    var token = myToken;
    if (token != null && token != "null") {
      String url = Api.myActivities+id.toString()+"/activities/";
      http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + token,
        },
      ).then((onValue) {
        if (onValue.statusCode == 200) {
          final dataOrders = json.decode(onValue.body) as Map<String, dynamic>;
          groupActivities = dataOrders["results"];
          groupActivityDetails = dataOrders;
          isLoadingGroups = false;
          notifyListeners();
        } else {
          groupActivities = [];
          groupActivityDetails = {};
          isLoadingGroups = false;
          notifyListeners();
        }
      });
    }
  }

  Map get allGroupActivityDetails{
    return groupActivityDetails;
  }

  List get groupActivity{
    return groupActivities;
  }



}
