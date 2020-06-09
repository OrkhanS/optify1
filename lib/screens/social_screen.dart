import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/models/api.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:optifyapp/screens/globalSearch.dart';
import 'package:optifyapp/screens/item_screen.dart';
import 'package:optifyapp/main.dart';
import 'package:optifyapp/screens/add_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:optifyapp/widgets/filter_bar.dart';

import 'package:optifyapp/providers/ordersandtrips.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialScreen extends StatefulWidget {
  static const routeName = '/social';
  var token, contactsGroupsProvider, user_id;
  SocialScreen({this.token, this.contactsGroupsProvider, this.user_id});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
//  var deviceSize = MediaQuery.of(context).size;
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List _contacts = [];
  String token, user_id;
  bool contactRequestAccepted = false;
  Map _contactsDetails = {};
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

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

  Future removeContact(i) async {
    String url = Api.removeContactRequst + _contacts[i]["id"].toString() + "/";
    http.delete(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );
    Provider.of<ContactsGroups>(context).removeContact(i);
  }

  Future respondContactRequest(i) async {
    String url = Api.respondContactRequst + _contacts[i]["id"].toString() + "/respond/";
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({"response":"acc"}))
        .then((response) {
      if (response.statusCode == 200) {
        setState(
          () {
            // Provider.of<ContactsGroups>(context).fetchAndSetMyContacts(token);
            contactRequestAccepted = true;
          },
        );
      }
    });
    Provider.of<ContactsGroups>(context).removeContact(i);
  }

  @override
  void initState() {
    if (widget.token == null || widget.user_id == null) {
      getToken();
    } else {
      token = widget.token;
      user_id = widget.user_id;
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
    String url = Api.userslistAndSignUp;
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
          _suggested = dataOrders["results"];
          // isLoading = false;
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
//        items.addAll( ['item 1']);
//        print('items: '+ items.toString());
          _isfetchingnew = false;
        });
      } else {
        _isfetchingnew = false;
      }
    }

    //print(widget.orderstripsProvider.orders);
    return Consumer<ContactsGroups>(
      builder: (context, contactsGroupsProvider, child) {
        if (Provider.of<ContactsGroups>(context, listen: true).contacts != 0) {
          _contacts = contactsGroupsProvider.contacts;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = contactsGroupsProvider.detailsContacts["next"];
          }
          //messageLoader = false;
        } else {
          //messageLoader = true;
        }

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Social",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GlobalSearchScreen(
                          token: token,
                          contactsGroupsProvider:
                              widget.contactsGroupsProvider)));
            },
            tooltip: 'First button',
            child: Icon(Icons.search, color: Colors.white),
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
                                onFieldSubmitted: (value) {},
                              ),
                            ),
                          ],
                        ),
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
                                            scrollInfo
                                                .metrics.maxScrollExtent) {
                                      // start loading data
                                      setState(() {
                                        _isfetchingnew = true;
                                      });
                                      _loadData();
                                    }
                                  },
                                  child: ListView.builder(
                                    itemBuilder: (context, int i) {
                                      if (_contacts[i]["requester"]["id"] ==
                                          user_id) {
                                        _contactsDetails =
                                            _contacts[i]["requester"];
                                      } else {
                                        _contactsDetails =
                                            _contacts[i]["reciever"];
                                      }
                                      var nameSur =
                                          _contactsDetails["first_name"]
                                                  .toString() +
                                              " " +
                                              _contactsDetails["last_name"]
                                                  .toString();
                                      if (nameSur == " ")
                                        nameSur = "Hidden Name";
                                      return Container(
                                        height: 100,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Card(
                                          elevation: 4,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Image(
                                                image: NetworkImage(
                                                    "https://robohash.org/" +
                                                        _contactsDetails["id"]
                                                            .toString()),
                                                height: 80,
                                                width: 90,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14.0,
                                                        horizontal: 2),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      nameSur,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.alternate_email,
                                                          size: 10,
//                                            (FontAwesome.suitcase),
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        Text(
                                                          _contactsDetails[
                                                                  "username"]
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600]),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              _contacts[i]["requester"]["id"]
                                                          .toString() ==
                                                      user_id.toString()
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 5),
                                                      child: _contacts[i]
                                                                  ["state"] ==
                                                              "req"
                                                          ? RaisedButton(
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (ctx) =>
                                                                      AlertDialog(
                                                                    content:
                                                                        Text(
                                                                      "Do you want to cancel Request?",
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'No.'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'Yes, cancel!',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.redAccent,
                                                                            )),
                                                                        onPressed:
                                                                            () {
                                                                              Navigator.of(ctx)
                                                                              .pop();
                                                                          removeContact(i);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "Pending",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : RaisedButton(
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                removeContact(i);
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .remove_circle_outline,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "Remove",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    )
                                                  : Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10.0,
                                                          horizontal: 5),
                                                      child: _contacts[i]
                                                                  ["state"] !=
                                                              "req"
                                                          ? 
                                                            RaisedButton(
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {},
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .remove_circle_outline,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "Remove2",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ) :

                                                            contactRequestAccepted ? 
                                                            RaisedButton(
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (ctx) =>
                                                                      AlertDialog(
                                                                    content:
                                                                        Text(
                                                                      "Do you want to remove Contact?",
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'No.'),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'Yes, remove!',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.redAccent,
                                                                            )),
                                                                        onPressed:
                                                                            () {
                                                                              Navigator.of(ctx)
                                                                              .pop();
                                                                          removeContact(i);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                          
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "Friends",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                         
                                                        : RaisedButton(
                                                              color:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                respondContactRequest(i);
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "Accept",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
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
                                    itemCount: _contacts.length,
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
          ),
        );
      },
    );
  }
}
