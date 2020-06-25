import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/models/api.dart';
import 'package:optifyapp/screens/global_search.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_group.dart';
import 'contact_screen.dart';

class ManageParticipants extends StatefulWidget {
  static const routeName = '/social';
  var token, user_id;

  ManageParticipants(
      {this.token, this.user_id});

  @override
  _ManageParticipantsState createState() => _ManageParticipantsState();
}

class _ManageParticipantsState extends State<ManageParticipants> {
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  bool searchFlag = false;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List _contacts = [];
  String token, user_id;
  Map _contactsDetails = {};
  List memberListForActivityMembers = [];
  List titleOfGroup = [];
  
  final TextEditingController _typeAheadController = TextEditingController();

  loadMycontacts() {
    if (Provider.of<ContactsGroups>(context, listen: true).contacts.isEmpty) {
      Provider.of<ContactsGroups>(context, listen: true)
          .fetchAndSetMyContacts(widget.token);
    }
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    setState(() {
      token = extractedUserData["token"];
      user_id = extractedUserData['user_id'].toString();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future getSuggestions(pattern) async {
    Provider.of<ContactsGroups>(context).isLoadingContacts = true;
    String url = Api.userslistAndSignUp + "?username=" + pattern;
    await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _contacts.clear();
          _contacts.addAll(dataOrders["results"]);
          searchFlag = true;
          Provider.of<ContactsGroups>(context).isLoadingContacts = false;
        },
      );
    });
    return _suggested;
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    loadMycontacts();
    if (widget.token == null || widget.user_id == null) {
      getToken();
    } else {
      token = widget.token;
      user_id = widget.user_id;
    }
    Future _loadData() async {
      if (nextOrderURL.toString() != "null" &&
          nextOrderURL.toString() != "FristCall") {
        String url = nextOrderURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + widget.token,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _contacts.addAll(dataOrders["results"]);
            nextOrderURL = dataOrders["next"];
          });
        } catch (e) {
          print("Some Error");
        }
        setState(() {
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    //print(widget.orderstripsProvider.orders);
    return Consumer<ContactsGroups>(
      builder: (context, contactsGroupsProvider, child) {
        if (_contacts.isEmpty && !searchFlag) {
          if (Provider.of<ContactsGroups>(context, listen: true).contacts !=
              0) {
            _contacts.addAll(contactsGroupsProvider.detailsContacts["results"]);
            if (nextOrderURL == "FirstCall") {
              nextOrderURL = contactsGroupsProvider.detailsContacts["next"];
            }
          } else {}
        }
        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Provider.of<ContactsGroups>(context).activityMemberList=memberListForActivityMembers;

              Navigator.of(context).pop();
              setState(() { 
                
              });
            },
            child: Icon(Icons.subdirectory_arrow_right),
          ),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.chevron_left,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Participiants",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * .83,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: this._typeAheadController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                        labelText: 'Search',
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          padding: EdgeInsets.only(
                            top: 5,
                          ),
                          icon: Icon(
                            Icons.close,
                            size: 15,
                          ),
                          onPressed: () {
                            this._typeAheadController.text = '';
                            _typeAheadController.clear();
                            setState(() {
                              searchFlag = false;
                              _contacts.clear();
                            });
                          },
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        searchFlag = true;
                        getSuggestions(value);
                      },
                    ),
                  ),
                  Expanded(
                    child: contactsGroupsProvider.notLoadingContacts ||
                            user_id == null
                        ? Center(child: CircularProgressIndicator())
                        : contactsGroupsProvider.contacts.isEmpty
                            ? Center(child: Text("No contacts"))
                            : NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (!_isfetchingnew &&
                                      scrollInfo.metrics.pixels ==
                                          scrollInfo.metrics.maxScrollExtent) {
                                    // start loading data
                                    setState(() {
                                      _isfetchingnew = true;
                                    });
                                    _loadData();
                                  }
                                },
                                child: ListView.builder(
                                  itemCount: _contacts.length,
                                  itemBuilder: (context, int i) {
                                    return Column(
                                      children: <Widget>[
                                        ContactCard(
                                          title: titleOfGroup,
                                          memberListForActivityMembers:
                                              memberListForActivityMembers,
                                          searchFlag: searchFlag,
                                          contacts: _contacts,
                                          i: i,
                                          token: token,
                                          userId: user_id,
                                        ),
                                        SizedBox(height: 3)
                                      ],
                                    );
                                  },
                                ),
                              ),
                  ),
                  Container(
                    height: _isfetchingnew ? 50.0 : 0.0,
                    color: Colors.transparent,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ContactCard extends StatefulWidget {
  final contacts, i, token, userId, searchFlag, memberListForActivityMembers, title;

  ContactCard(
      {@required this.memberListForActivityMembers,
      @required this.searchFlag,
      @required this.contacts,
      @required this.i,
      @required this.token,
      @required this.userId,
      @required this.title});

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  var contactsDetails;
  var check = false;
  Map memberObject = {};

  @override
  Widget build(BuildContext context) {
    if (widget.searchFlag == false) {
      if (widget.contacts[widget.i]["requester"]["id"].toString() ==
          widget.userId.toString()) {
        contactsDetails = widget.contacts[widget.i]["reciever"];
      } else {
        contactsDetails = widget.contacts[widget.i]["requester"];
      }
    } else {
      contactsDetails = widget.contacts[widget.i];
    }
    var nameSur = contactsDetails["first_name"].toString() +
        " " +
        contactsDetails["last_name"].toString();
    if (nameSur == " ") nameSur = "Hidden Name";
    return CheckboxListTile(
      value: check,
      title: Text(nameSur,
          style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold)),
      subtitle: Text(contactsDetails["username"].toString(),
          style: TextStyle(color: Colors.grey[600])),
      onChanged: (val) {
        var flag=false;
        for(var x=0;x<widget.memberListForActivityMembers.length;x++){
          if(widget.memberListForActivityMembers[x]["id"] == contactsDetails["id"]){
            flag=true;
            widget.memberListForActivityMembers.removeAt(x);  
          }
        }
        if (!flag) {
          memberObject["id"] = contactsDetails["id"];
          memberObject["type"] = "user"; // group or user
          memberObject["name"] = nameSur;
          widget.memberListForActivityMembers.add(memberObject);
          memberObject = {};
        }
        
        check = val;
      },
      secondary: Image(
        height: 80,
        frameBuilder: (BuildContext context, Widget child, int frame,
            bool wasSynchronouslyLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: child,
          );
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes
                : null,
          );
        },
        image: NetworkImage(
          "https://robohash.org/" + contactsDetails["id"].toString(),
        ),
      ),
    );
  }
}
