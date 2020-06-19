import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/models/api.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:optifyapp/screens/item_screen.dart';
import 'package:optifyapp/main.dart';
import 'package:optifyapp/screens/add_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:optifyapp/widgets/filter_bar.dart';

import 'package:optifyapp/providers/ordersandtrips.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSearchScreen extends StatefulWidget {
  static const routeName = '/globalSearch';
  var token, contactsGroupsProvider;
  GlobalSearchScreen({this.token, this.contactsGroupsProvider});

  @override
  _GlobalSearchScreenState createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List contacts = [];
  var requestSent;
  String token;
  var snackBar;
  bool loadingContacts = false;
  final TextEditingController _typeAheadController = TextEditingController();

  getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    token = extractedUserData["token"];
  }

  @override
  void initState() {
    if (widget.token == null) {
      getToken();
    } else {
      token = widget.token;
    }
    super.initState();
  }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future getSuggestions(pattern) async {
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
          contacts.clear();
          contacts.addAll(dataOrders["results"]);
          loadingContacts = false;
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactsGroups>(
      builder: (context, contactsGroupsProvider, child) {
        return Scaffold(
          resizeToAvoidBottomPadding: true,
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
              "Social",
              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
            elevation: 1,
          ),
          body: GestureDetector(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * .83,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
//                                controller: _typeAheadController4,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                  ),
                                  labelText: 'Search',
                                  hintText: 'Username',
                                  hintStyle: TextStyle(color: Colors.grey[300]),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.only(
                                      top: 5,
                                    ),
                                    icon: Icon(
                                      Icons.close,
                                      size: 15,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                onFieldSubmitted: (value) {
                                  loadingContacts = true;
                                  getSuggestions(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: loadingContacts
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemBuilder: (context, int i) {
                                var nameSur = contacts[i]["first_name"].toString() + " " + contacts[i]["last_name"].toString();
                                if (nameSur == " ") nameSur = "Hidden Name";
                                return Container(
                                  height: 100,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Card(
                                    elevation: 4,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Image(
                                          image: NetworkImage("https://robohash.org/" + contacts[i]["id"].toString()),
                                          height: 80,
                                          width: 90,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 2),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                nameSur,
                                                style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.alternate_email,
                                                    size: 10,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                  Text(
                                                    contacts[i]["username"].toString(),
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        contacts[i]["contact_status"] == null
                                            ? Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                                                child: requestSent != i
                                                    ? RaisedButton(
                                                        color: Colors.white,
                                                        onPressed: () {
                                                          Provider.of<ContactsGroups>(context).requestContact(contacts[i]["id"], token);
                                                          setState(
                                                            () {
                                                              requestSent = i;
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.add,
                                                                color: Theme.of(context).primaryColor,
                                                                size: 20,
                                                              ),
                                                              Text(
                                                                "Add",
                                                                style: TextStyle(
                                                                  color: Theme.of(context).primaryColor,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : RaisedButton(
                                                        color: Colors.white,
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (ctx) => AlertDialog(
                                                              content: Text(
                                                                "Do you want to remove Request?",
                                                              ),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text('No.'),
                                                                  onPressed: () {
                                                                    Navigator.of(ctx).pop();
                                                                  },
                                                                ),
                                                                FlatButton(
                                                                  child: Text('Yes!',
                                                                      style: TextStyle(
                                                                        color: Colors.redAccent,
                                                                      )),
                                                                  onPressed: () {
                                                                    Navigator.of(ctx).pop();
                                                                    setState(
                                                                      () {
                                                                        requestSent = false;
                                                                      },
                                                                    );
                                                                    Provider.of<ContactsGroups>(context).removeContactOrRequest(i, token);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.done,
                                                                color: Theme.of(context).primaryColor,
                                                                size: 20,
                                                              ),
                                                              Text(
                                                                "Sent",
                                                                style: TextStyle(
                                                                  color: Theme.of(context).primaryColor,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                                                child: RaisedButton(
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        content: Text(
                                                          "Do you want to remove Request?",
                                                        ),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('No.'),
                                                            onPressed: () {
                                                              Navigator.of(ctx).pop();
                                                            },
                                                          ),
                                                          FlatButton(
                                                            child: Text('Yes!',
                                                                style: TextStyle(
                                                                  color: Colors.redAccent,
                                                                )),
                                                            onPressed: () {
                                                              Navigator.of(ctx).pop();
                                                              setState(
                                                                () {
                                                                  requestSent = false;
                                                                },
                                                              );
                                                              Provider.of<ContactsGroups>(context).removeContactOrRequest(i, token);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.done_all,
                                                          color: Theme.of(context).primaryColor,
                                                          size: 20,
                                                        ),
                                                        Text(
                                                          "Friend",
                                                          style: TextStyle(
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: contacts.length,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
