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
import 'package:optifyapp/screens/global_search.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_screen.dart';

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
  Map _contactsDetails = {};

  loadMycontacts() {
    if (Provider.of<ContactsGroups>(context, listen: true).contacts.isEmpty) {
      Provider.of<ContactsGroups>(context, listen: true).fetchAndSetMyContacts(widget.token);
    }
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

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
      if (nextOrderURL.toString() != "null" && nextOrderURL.toString() != "FristCall") {
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
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GlobalSearchScreen(token: token, contactsGroupsProvider: widget.contactsGroupsProvider)));
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
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                    ),
                    Expanded(
                      child: contactsGroupsProvider.notLoadingContacts || user_id == null
                          ? Center(child: CircularProgressIndicator())
                          : contactsGroupsProvider.contacts.isEmpty
                              ? Center(child: Text("No contacts"))
                              : NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    if (!_isfetchingnew && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                      // start loading data
                                      setState(() {
                                        _isfetchingnew = true;
                                      });
                                      _loadData();
                                    }
                                  },
                                  child: ListView.builder(
                                    itemCount: _contacts.length,
                                    padding: EdgeInsets.all(20),
                                    itemBuilder: (context, int i) {
                                      return Column(
                                        children: <Widget>[
                                          ContactCard(
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
          ),
        );
      },
    );
  }
}

class ContactCard extends StatefulWidget {
  final contacts, i, token, userId;

  ContactCard({@required this.contacts, @required this.i, @required this.token, @required this.userId});

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  var contactsDetails;

  @override
  Widget build(BuildContext context) {
    if (widget.contacts[widget.i]["requester"]["id"].toString() == widget.userId.toString()) {
      contactsDetails = widget.contacts[widget.i]["reciever"];
    } else {
      contactsDetails = widget.contacts[widget.i]["requester"];
    }
    var nameSur = contactsDetails["first_name"].toString() + " " + contactsDetails["last_name"].toString();
    if (nameSur == " ") nameSur = "Hidden Name";
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactScreen(contact: contactsDetails)),
                );
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: Image.network(
                        "https://robohash.org/" + contactsDetails["id"].toString(),
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      )),
                  Expanded(
                    flex: 2,
                    child: Padding(
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
                                contactsDetails["username"].toString(),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10, height: 80),
          Expanded(
            flex: 3,
            child: Padding(
                //If I sent friend request
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                child: // If another person hasn't accepted my request yet.
                    OutlineButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  // If I want to cancel my Pending
                  onPressed: () {
                    if (widget.contacts[widget.i]["requester"]["id"].toString() == widget.userId.toString()) {
                      if (widget.contacts[widget.i]["state"].toString() == "req") {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: Text(
                              "Do you want to cancel Request?",
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
                                  Provider.of<ContactsGroups>(context).removeContactOrRequest(widget.i, widget.token);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
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
                                  Provider.of<ContactsGroups>(context).removeContactOrRequest(widget.i, widget.token);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      if (widget.contacts[widget.i]["state"].toString() == "req") {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: Text(
                              "Do you want to Accept or Remove the request?",
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Accept.'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  Provider.of<ContactsGroups>(context).acceptContactRequest(widget.i, widget.token);
                                  setState(
                                    () {
                                      widget.contacts[widget.i]["state"] = "acc";
                                    },
                                  );
                                },
                              ),
                              FlatButton(
                                child: Text('Remove.',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    )),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  Provider.of<ContactsGroups>(context).removeContactOrRequest(widget.i, widget.token);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: Text(
                              "Do you want to remove Contact?",
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
                                  Provider.of<ContactsGroups>(context).removeContactOrRequest(widget.i, widget.token);
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: widget.contacts[widget.i]["requester"]["id"].toString() == widget.userId.toString()
                          ? (widget.contacts[widget.i]["state"].toString() == "req")
                              ? Text(
                                  "Pending",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )
                          : widget.contacts[widget.i]["state"].toString() == "req"
                              ? Text(
                                  "Respond",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                )),
                )),
          ),
        ],
      ),
    );
  }
}
