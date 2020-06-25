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
import 'package:optifyapp/screens/global_search.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_group.dart';
import 'contact_screen.dart';
import 'group_screen.dart';

class SocialScreen extends StatefulWidget {
  static const routeName = '/social';
  var token, contactsGroupsProvider, user_id;

  SocialScreen({this.token, this.contactsGroupsProvider, this.user_id});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _typeAheadController = TextEditingController();

//  var deviceSize = MediaQuery.of(context).size;
  bool expands = false;
  var filterColor = Colors.white;
  var _itemCount = 0;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List _contacts = [];
  bool searchFlag = false;
  String token, user_id;
  Map _contactsDetails = {};
  List requestSent = [];
  List _combinedList = [];

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
        if (_contacts.isEmpty && !searchFlag) {
          if (_combinedList.isEmpty) {
            _combinedList.addAll(contactsGroupsProvider.combinedList["contacts"]["results"]);
            _combinedList.addAll(contactsGroupsProvider.combinedList["groups"]["results"]);

            // _combinedList.shuffle();
            if (nextOrderURL == "FirstCall") {
              nextOrderURL = contactsGroupsProvider.detailsContacts["next"];
            }
          } else {}
        }

        return Scaffold(
          resizeToAvoidBottomPadding: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: RaisedButton(
            elevation: 7,
            color: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddGroupScreen(contactsGroupsProvider: contactsGroupsProvider, searchFlag: searchFlag)));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.add, color: Theme.of(context).primaryColor),
                Text(
                  "New Group",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height * .9,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _typeAheadController,
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
                          _typeAheadController.clear();
                          setState(() {
                            searchFlag = false;
                            requestSent = [];
                            _contacts.clear();
                          });
                        },
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      getSuggestions(value);
                    },
                    onChanged: (value) {
                      //todo rasul
                      if (value == "") {
                        setState(() {
                          searchFlag = false;
                          requestSent = [];
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: contactsGroupsProvider.notLoadingContacts || user_id == null
                      ? Center(child: CircularProgressIndicator())
                      : _combinedList.isEmpty
                          ? Center(child: Text("No contacts"))
                          : ListView.builder(
                              itemCount: contactsGroupsProvider.lengthLists,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              itemBuilder: (context, int i) {
                                return Column(
                                  children: <Widget>[
                                    _combinedList[i]["requester"] != null
                                        ? ContactCard(
                                            requestSent: requestSent,
                                            searchFlag: searchFlag,
                                            contacts: _combinedList,
                                            i: i,
                                            token: token,
                                            userId: user_id,
                                          )
                                        : GroupCard(
                                            groups: _combinedList,
                                            i: i,
                                            token: token,
                                            provider: contactsGroupsProvider,
                                          ),
                                    Divider(),
                                  ],
                                );
                              },
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
        );
      },
    );
  }
}

class ContactCard extends StatefulWidget {
  final contacts, i, token, userId, searchFlag, requestSent;

  ContactCard(
      {@required this.requestSent,
      @required this.contacts,
      @required this.i,
      @required this.token,
      @required this.userId,
      @required this.searchFlag});

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  var contactsDetails;
  @override
  Widget build(BuildContext context) {
    if (widget.searchFlag == false) {
      if (widget.contacts[widget.i]["requester"]["id"].toString() == widget.userId.toString()) {
        contactsDetails = widget.contacts[widget.i]["reciever"];
      } else {
        contactsDetails = widget.contacts[widget.i]["requester"];
      }
    } else {
      contactsDetails = widget.contacts[widget.i];
    }

    var nameSur = contactsDetails["first_name"].toString() + " " + contactsDetails["last_name"].toString();
    if (nameSur == " ") nameSur = "Hidden Name";
    return Container(
      height: 60,
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
                      "https://robohash.org/" + contactsDetails["username"].toString() + "?set=set5",
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
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          Expanded(
            flex: 3,
            child: Padding(
                //If I sent friend request
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  child: widget.searchFlag == false
                      ? widget.contacts[widget.i]["requester"]["id"].toString() == widget.userId.toString()
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
                                )
                      : widget.contacts[widget.i]["contact_status"] == null
                          ? !widget.requestSent.contains(widget.i)
                              ? InkWell(
                                  onTap: () {
                                    Provider.of<ContactsGroups>(context)
                                        .requestContact(widget.contacts[widget.i]["id"], Provider.of<Auth>(context).myToken);
                                    setState(
                                      () {
                                        widget.requestSent.add(widget.i);
                                      },
                                    );
                                  },
                                  child: Row(
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
                                      ),
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
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
                                                  widget.requestSent.remove(widget.i);
                                                },
                                              );
                                              Provider.of<ContactsGroups>(context)
                                                  .removeContactOrRequest(widget.i, Provider.of<Auth>(context).myToken);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Row(
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
                                )
                          : widget.contacts[widget.i]["contact_status"] == "acc"
                              ? InkWell(
                                  onTap: () {
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
                                                  widget.requestSent.remove(widget.i);
                                                },
                                              );
                                              Provider.of<ContactsGroups>(context)
                                                  .removeContactOrRequest(widget.i, Provider.of<Auth>(context).myToken);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
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
                                                  widget.requestSent.remove(widget.i);
                                                },
                                              );
                                              Provider.of<ContactsGroups>(context)
                                                  .removeContactOrRequest(widget.i, Provider.of<Auth>(context).myToken);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sent",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                )),
          ),
        ],
      ),
    );
  }
}

class GroupCard extends StatefulWidget {
  final groups, i, token, provider;

  GroupCard({@required this.groups, @required this.i, @required this.token, @required this.provider});

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: InkWell(
              onTap: () {
                widget.provider.fetchAndSetGroupActivities(widget.token, widget.groups[widget.i]["schedule"]["id"]);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupScreen(group: widget.groups[widget.i], provider: widget.provider)),
                );
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Image.network(
                      "https://robohash.org/" + widget.groups[widget.i]["name"].toString(),
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
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.groups[widget.i]["name"].toString(),
                            maxLines: 1,
                            style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "@" + widget.groups[widget.i]["groupmembers"][0]["member"]["username"].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (widget.groups[widget.i]["groupmembers"][1]["member"]["username"] != null)
                            Text(
                              "@" + widget.groups[widget.i]["groupmembers"][1]["member"]["username"].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10, height: 60),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: OutlineButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {},
                child: Text(
                  "View Schedule",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
