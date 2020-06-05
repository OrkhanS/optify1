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
  var token, contactsGroupsProvider;
  SocialScreen({this.token, this.contactsGroupsProvider});

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
  String token;
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
    if(widget.token == null){
      getToken();
    }else{
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

 FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.userslistAndSignUp;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json",
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
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            child: TypeAheadFormField(
                              keepSuggestionsOnLoading: false,
                              debounceDuration:
                                  const Duration(milliseconds: 200),
                              textFieldConfiguration: TextFieldConfiguration(
                                onChanged: (value) {
                                  // widget.from = null;
                                },
                                controller: this._typeAheadController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText: 'Username',
                                  hintStyle: TextStyle(color: Colors.grey[300]),
                                  prefixIcon: Icon(
                                    Icons.person
                                  ),
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
                                      // widget.from = null;
                                    },
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return getSuggestions(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(
                                      suggestion["first_name"] == "" ? "Hidden Name" : 
                                      suggestion["first_name"] +"  "+ suggestion["last_name"]),
                                );
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              onSuggestionSelected: (suggestion) {
                                // this._typeAheadController.text =
                                //     suggestion.toString().split(", ")[0] +
                                //         ", " +
                                //         suggestion.toString().split(", ")[1];
                                // widget.from =
                                //     suggestion.toString().split(", ")[2];
                                // _searchBarFrom =
                                //     suggestion.toString().split(", ")[0];
                              },
                              validator: (value) {
                                // widget.from = value;

                                if (value.isEmpty) {
                                  return 'Please select a city';
                                }
                              },
                              onSaved: (value) {
                                // widget.from = value;
                              },
                            ),
                          ),
                       
//                                TextFormField(
// //                                controller: _typeAheadController4,
//                                 decoration: InputDecoration(
//                                   prefixIcon: Icon(
//                                     Icons.search,
//                                   ),
//                                   labelText: 'Search',
//                                   hintText: 'Username',
//                                   hintStyle: TextStyle(color: Colors.grey[300]),
//                                   suffixIcon: IconButton(
//                                     padding: EdgeInsets.only(
//                                       top: 5,
//                                     ),
//                                     icon: Icon(
//                                       Icons.close,
//                                       size: 15,
//                                     ),
//                                     onPressed: () {
// //                                      this._typeAheadController4.text = '';
// //                      widget.price = null;
//                                     },
//                                   ),
//                                 ),
//                               ),
                            
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: contactsGroupsProvider.notLoadingContacts
                          ? Center(child: CircularProgressIndicator())
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
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
                                itemBuilder: (context, int i) {
                                  var nameSur =
                                      _contacts[i]["first_name"].toString() +
                                          " " +
                                          _contacts[i]["last_name"].toString();
                                  if (nameSur == " ") nameSur = "Hidden Name";
                                  return Container(
                                    height: 100,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Card(
                                      elevation: 4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Image(
                                            image: NetworkImage(
                                                "https://robohash.org/" +
                                                    _contacts[i]["id"]
                                                        .toString()),
                                            height: 80,
                                            width: 90,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14.0, horizontal: 2),
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
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.alternate_email,
                                                      size: 10,
//                                            (FontAwesome.suitcase),
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    Text(
                                                      _contacts[i]["username"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 5),
                                            child: RaisedButton(
                                              color: Colors.white,
                                              onPressed: () {
//                                                createRooms(tripsProvider.trips[i]["owner"]["id"]);
//                                                Flushbar(
//                                                  title: "Chat with " + _trips[i]["owner"]["first_name"].toString() + " has been started!",
//                                                  message: "Check Chats to see more.",
//                                                  aroundPadding: const EdgeInsets.all(8),
//                                                  borderRadius: 10,
//                                                  duration: Duration(seconds: 5),
//                                                )..show(context);
                                                //Todo Toast message that Conversation has been started
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //       builder: (context) => MyApp()),
                                                // );
                                                //Navigator.pop(context);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.add,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      "Add",
                                                      style: TextStyle(
//                                                        fontWeight: FontWeight.bold,
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
//                                  return InkWell(
//                                    onTap: () {},
//                                    child: Container(
//                                      height: 130,
//                                      padding: EdgeInsets.symmetric(horizontal: 10),
//                                      child: Card(
//                                        elevation: 4,
//                                        child: Row(
//                                          children: <Widget>[
//                                            Expanded(
//                                              flex: 3,
//                                              child: CircleAvatar(
//                                                radius: 60,
//                                                backgroundColor: Colors.white,
//                                                backgroundImage: NetworkImage("https://robohash.org/" + _contacts[i]["id"].toString()), //Todo
//                                              ),
//                                            ),
////                                            Padding(
////                                              padding:
////                                                  const EdgeInsets.all(10.0),
////                                              child: ClipRRect(
////                                                borderRadius: BorderRadius.all(
////                                                    Radius.circular(15)),
////                                                child: Image(
////                                                  loadingBuilder:
////                                                      (BuildContext context,
////                                                          Widget child,
////                                                          ImageChunkEvent
////                                                              loadingProgress) {
////                                                    if (loadingProgress == null)
////                                                      return child;
////                                                    return Center(
////                                                      child:
////                                                          CircularProgressIndicator(
////                                                        value: loadingProgress
////                                                                    .expectedTotalBytes !=
////                                                                null
////                                                            ? loadingProgress
////                                                                    .cumulativeBytesLoaded /
////                                                                loadingProgress
////                                                                    .expectedTotalBytes
////                                                            : null,
////                                                      ),
////                                                    );
////                                                  },
////
////                                                  image: NetworkImage(
////                                                      // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
////                                                      "https://picsum.photos/250?image=9"), //Todo,
////                                                ),
////                                              ),
////                                            ),
//                                            Expanded(
//                                              flex: 5,
//                                              child: Padding(
//                                                padding: const EdgeInsets.all(12.0),
//                                                child: Column(
//                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                                  children: <Widget>[
//                                                    SizedBox(
//                                                      width: 200,
//                                                      child: Text(
////                                                    _contacts[i]["title"].toString().length > 20
////                                                        ? _contacts[i]["title"].toString().substring(0, 20) + "..."
////                                                        :
//                                                        _contacts[i]["username"].toString(), //Todo: title
//                                                        overflow: TextOverflow.ellipsis,
//                                                        maxLines: 1,
//                                                        style: TextStyle(
//                                                          fontSize: 20,
//                                                          color: Colors.grey[800],
////                                          fontWeight: FontWeight.bold,
//                                                        ),
//                                                      ),
//                                                    ),
//                                                    Row(
//                                                      mainAxisAlignment: MainAxisAlignment.start,
//                                                      children: <Widget>[
//                                                        Icon(
//                                                          MdiIcons.mapMarkerMultipleOutline,
//                                                          color: Theme.of(context).primaryColor,
//                                                        ),
//                                                        SizedBox(
//                                                          width: 200,
//                                                          child: Text(
//                                                            _contacts[i]["first_name"].toString() + " " + _contacts[i]["last_name"].toString(),
//                                                            //Todo: Source -> Destination
//                                                            maxLines: 1,
//                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
//                                                          ),
//                                                        ),
//                                                      ],
//                                                    ),
////                                                   Row(
//// //                                        mainAxisSize: MainAxisSize.max,
////                                                     mainAxisAlignment:
////                                                         MainAxisAlignment
////                                                             .spaceAround,
////                                                     children: <Widget>[
////                                                       Row(
////                                                         children: <Widget>[
////                                                           Icon(
////                                                             MdiIcons
////                                                                 .calendarRange,
////                                                             color: Theme.of(
////                                                                     context)
////                                                                 .primaryColor,
////                                                           ),
////                                                           Text(
////                                                             _contacts[i]["date"]
////                                                                 .toString(),
////                                                             //Todo: date
////                                                             style: TextStyle(
////                                                                 color: Colors
////                                                                     .grey[600]),
////                                                           ),
////                                                         ],
////                                                       ),
////                                                       SizedBox(
////                                                         width: 50,
////                                                       ),
////                                                     ],
////                                                   ),
//                                                  ],
//                                                ),
//                                              ),
//                                            ),
//                                            Expanded(
//                                              flex: 2,
//                                              child: FlatButton(
//                                                onPressed: () {},
//                                              ),
//                                            ),
//                                          ],
//                                        ),
//                                      ),
//                                    ),
//                                  );
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

class SearchBar extends StatefulWidget {
  var from, to, weight, price;
  OrdersTripsProvider ordersProvider;
  SearchBar({this.ordersProvider, this.from, this.to, this.weight, this.price});
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  final TextEditingController _typeAheadController3 = TextEditingController();
  final TextEditingController _typeAheadController4 = TextEditingController();

  String _searchBarFrom = "Anywhere";
  String _searchBarTo = "Anywhere";
  String _searchBarWeight = "Any";

  List _suggested = [];
  List _cities = [];
  bool isLoading = true;

  bool flagFrom = false;
  bool flagTo = false;
  bool flagWeight = false;
  String urlFilter = "";
  var _expanded = false;

  Future filterAndSetOrders() async {
    urlFilter = "http://briddgy.herokuapp.com/api/orders/?";
    if (widget.from != null) {
      urlFilter = urlFilter + "origin=" + widget.from;
      flagFrom = true;
    }
    if (widget.to != null) {
      flagFrom == false
          ? urlFilter = urlFilter + "dest=" + widget.to.toString()
          : urlFilter = urlFilter + "&dest=" + widget.to.toString();
      flagTo = true;
    }
    if (widget.weight != null) {
      flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "weight=" + widget.weight.toString()
          : urlFilter = urlFilter + "&weight=" + widget.weight.toString();
      flagWeight = true;
    }
    if (widget.price != null) {
      flagWeight == false && flagTo == false && flagFrom == false
          ? urlFilter = urlFilter + "min_price=" + widget.price.toString()
          : urlFilter = urlFilter + "&min_price=" + widget.price.toString();
    }
    await http.get(
      urlFilter,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          widget.ordersProvider.orders = dataOrders["results"];
          isLoading = false;
          //itemCount = dataOrders["count"];
        },
      );
    });
  }

  FutureOr<Iterable> getSuggestions(String pattern) async {
    String url = Api.userslistAndSignUp;
    await http.get(
      url,
      headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
    ).then((response) {
      setState(
        () {
          final dataOrders = json.decode(response.body) as Map<String, dynamic>;
          _suggested = dataOrders["results"];
          isLoading = false;
        },
      );
    });
    return _suggested;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? 480 : 80,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: TypeAheadFormField(
                    keepSuggestionsOnLoading: false,
                    debounceDuration: const Duration(milliseconds: 200),
                    textFieldConfiguration: TextFieldConfiguration(
                      onChanged: (value) {
                        widget.from = null;
                      },
                      controller: this._typeAheadController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        prefixIcon: Icon(
                          MdiIcons.mapMarkerRightOutline,
                        ),
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
                            widget.from = null;
                          },
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.toString().split(", ")[0] +
                            ", " +
                            suggestion.toString().split(", ")[1]),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      this._typeAheadController.text =
                          suggestion.toString().split(", ")[0] +
                              ", " +
                              suggestion.toString().split(", ")[1];
                      widget.from = suggestion.toString().split(", ")[2];
                      _searchBarFrom = suggestion.toString().split(", ")[0];
                    },
                    validator: (value) {
                      widget.from = value;

                      if (value.isEmpty) {
                        return 'Please select a city';
                      }
                    },
                    onSaved: (value) {
                      widget.from = value;
                    },
                  ),
                ),

                // TextFormField(
                //   controller: _typeAheadController4,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(
                //       Icons.search,
                //     ),
                //     labelText: 'Search',
                //     hintText: 'Username',
                //     hintStyle: TextStyle(color: Colors.grey[300]),
                //     suffixIcon: IconButton(
                //       padding: EdgeInsets.only(
                //         top: 5,
                //       ),
                //       icon: Icon(
                //         Icons.close,
                //         size: 15,
                //       ),
                //       onPressed: () {
                //         this._typeAheadController4.text = '';

                //       },
                //     ),
                //   ),
                // ),
              ),
            ],
          ),
        ),
      ),
//      child: Card(
//        margin: EdgeInsets.all(10),
//        child: Column(
//          children: <Widget>[
//            InkWell(
////              highlightColor: Colors.yellow,
//              onTap: () {
//                setState(() {
////                  _expanded = !_expanded;
//                });
//              },
//              child: ListTile(
//                title: Container(
//                  decoration: BoxDecoration(
//                    borderRadius: BorderRadius.all(Radius.circular(5)),
//                    color: Colors.white,
//                    border: Border(),
//                  ),
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
//                    child: Text(
//                      "Search"
////                      _searchBarFrom + " - " + _searchBarTo + " , " + _searchBarWeight + " kg "
//                      ,
//                      style: TextStyle(color: Theme.of(context).primaryColor
//                          // Theme.of(context).primaryColor,
//                          // fontWeight: FontWeight.bold,
//                          // fontSize: 20
//                          ),
//                    ),
//                  ),
//                ),
//                leading: IconButton(
//                  icon: Icon(Icons.search),
//                  onPressed: () {
//                    setState(() {
//                      _expanded = !_expanded;
//                    });
//                  },
//                ),
//              ),
//            ),
//            AnimatedContainer(
//              duration: Duration(milliseconds: 300),
//              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//              height: _expanded ? 400 : 0,
//              child: Form(
//                child: Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
//                  child: ClipRRect(
//                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
//                    child: Column(
//                      children: <Widget>[
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                            child: TypeAheadFormField(
//                              keepSuggestionsOnLoading: false,
//                              debounceDuration: const Duration(milliseconds: 200),
//                              textFieldConfiguration: TextFieldConfiguration(
//                                onChanged: (value) {
//                                  widget.from = null;
//                                },
//                                controller: this._typeAheadController,
//                                decoration: InputDecoration(
//                                  labelText: 'From',
//                                  hintText: ' Paris',
//                                  hintStyle: TextStyle(color: Colors.grey[300]),
//                                  prefixIcon: Icon(
//                                    MdiIcons.mapMarkerRightOutline,
//                                  ),
//                                  suffixIcon: IconButton(
//                                    padding: EdgeInsets.only(
//                                      top: 5,
//                                    ),
//                                    icon: Icon(
//                                      Icons.close,
//                                      size: 15,
//                                    ),
//                                    onPressed: () {
//                                      this._typeAheadController.text = '';
//                                      widget.from = null;
//                                    },
//                                  ),
//                                ),
//                              ),
//                              suggestionsCallback: (pattern) {
//                                return getSuggestions(pattern);
//                              },
//                              itemBuilder: (context, suggestion) {
//                                return ListTile(
//                                  title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
//                                );
//                              },
//                              transitionBuilder: (context, suggestionsBox, controller) {
//                                return suggestionsBox;
//                              },
//                              onSuggestionSelected: (suggestion) {
//                                this._typeAheadController.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
//                                widget.from = suggestion.toString().split(", ")[2];
//                                _searchBarFrom = suggestion.toString().split(", ")[0];
//                              },
//                              validator: (value) {
//                                widget.from = value;
//
//                                if (value.isEmpty) {
//                                  return 'Please select a city';
//                                }
//                              },
//                              onSaved: (value) {
//                                widget.from = value;
//                              },
//                            ),
//                          ),
//                        ),
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                            child: TypeAheadFormField(
//                              keepSuggestionsOnLoading: false,
//                              debounceDuration: const Duration(milliseconds: 200),
//                              textFieldConfiguration: TextFieldConfiguration(
//                                onChanged: (value) {
//                                  widget.to = null;
//                                },
//                                controller: this._typeAheadController2,
//                                decoration: InputDecoration(
//                                  labelText: 'To',
//                                  hintText: ' Berlin',
//                                  hintStyle: TextStyle(color: Colors.grey[300]),
//                                  prefixIcon: Icon(
//                                    MdiIcons.mapMarkerCheckOutline,
//                                  ),
//                                  suffixIcon: IconButton(
//                                    padding: EdgeInsets.only(
//                                      top: 5,
//                                    ),
//                                    icon: Icon(
//                                      Icons.close,
//                                      size: 15,
//                                    ),
//                                    onPressed: () {
//                                      this._typeAheadController2.text = '';
//                                      widget.to = null;
//                                    },
//                                  ),
//                                ),
//                              ),
//                              suggestionsCallback: (pattern) {
//                                return getSuggestions(pattern);
//                              },
//                              itemBuilder: (context, suggestion) {
//                                return ListTile(
//                                  title: Text(suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1]),
//                                );
//                              },
//                              transitionBuilder: (context, suggestionsBox, controller) {
//                                return suggestionsBox;
//                              },
//                              onSuggestionSelected: (suggestion) {
//                                this._typeAheadController2.text = suggestion.toString().split(", ")[0] + ", " + suggestion.toString().split(", ")[1];
//                                widget.to = suggestion.toString().split(", ")[2];
//                                _searchBarTo = suggestion.toString().split(", ")[0];
//                              },
//                              validator: (value) {
//                                widget.to = value;
//                                if (value.isEmpty) {
//                                  return 'Please select a city';
//                                }
//                              },
//                              onSaved: (value) => widget.to = value,
//                            ),
//                          ),
//                        ),
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
//                            child: TextFormField(
//                              controller: _typeAheadController3,
//                              decoration: InputDecoration(
//                                prefixIcon: Icon(MdiIcons.weightKilogram),
//                                labelText: 'Weight maximum (in kg):',
//                                hintText: ' 3kg',
//                                hintStyle: TextStyle(color: Colors.grey[300]),
//                                suffixIcon: IconButton(
//                                  padding: EdgeInsets.only(
//                                    top: 5,
//                                  ),
//                                  icon: Icon(
//                                    Icons.close,
//                                    size: 15,
//                                  ),
//                                  onPressed: () {
//                                    this._typeAheadController3.text = '';
//                                    widget.weight = null;
//                                  },
//                                ),
//                              ),
//                              keyboardType: TextInputType.number,
////
//                              onChanged: (String val) {
//                                _searchBarWeight = val;
//                                widget.weight = val;
//                              },
//                              onSaved: (value) {
////                        _authData['email'] = value;
//                              },
//                            ),
//                          ),
//                        ),
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
//                            child: TextFormField(
//                              controller: _typeAheadController4,
//                              decoration: InputDecoration(
//                                prefixIcon: Icon(
//                                  MdiIcons.currencyUsd,
//                                ),
//
//                                labelText: 'Reward minimum (in usd):',
//                                hintText: ' 10\$',
//                                hintStyle: TextStyle(color: Colors.grey[300]),
//
//                                suffixIcon: IconButton(
//                                  padding: EdgeInsets.only(
//                                    top: 5,
//                                  ),
//                                  icon: Icon(
//                                    Icons.close,
//                                    size: 15,
//                                  ),
//                                  onPressed: () {
//                                    this._typeAheadController4.text = '';
//                                    widget.price = null;
//                                  },
//                                ),
//                                //icon: Icon(Icons.location_on),
//                              ),
//
//                              keyboardType: TextInputType.number,
////                      validator: (value) {
////                        if (value.isEmpty || !value.contains('@')) {
////                          return 'Invalid email!';
////                        } else
////                          return null; //Todo
////                      },
//                              onChanged: (String val) {
//                                widget.price = val;
//                              },
//                              onSaved: (value) {
////                        _authData['email'] = value;
//                              },
//                            ),
//                          ),
//                        ),
//                        Expanded(
//                          child: Padding(
//                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                            child: ClipRRect(
//                              borderRadius: BorderRadius.circular(10),
//                              child: RaisedButton(
//                                color: Theme.of(context).primaryColor,
//
//                                elevation: 2,
////                            color: Theme.of(context).primaryColor,
//                                child: Container(
//                                  decoration: BoxDecoration(),
//                                  width: MediaQuery.of(context).size.width,
//                                  child: Center(
//                                    child: Text(
//                                      "Search",
//                                      style: TextStyle(
//                                        fontSize: 19,
//                                        color: Colors.white,
////                                  fontWeight: FontWeight.bold,
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                onPressed: () {
//                                  filterAndSetOrders();
//                                  setState(() {
//                                    _expanded = !_expanded;
//                                  });
////    filterAndSetOrders(from, to, weight, price);
//                                },
//                              ),
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
//            )
//          ],
//        ),
//      ),
    );
  }
}
