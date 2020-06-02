import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/screens/item_screen.dart';
import 'package:optifyapp/main.dart';
import 'package:optifyapp/screens/add_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:optifyapp/widgets/filter_bar.dart';

import 'package:optifyapp/providers/ordersandtrips.dart';

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
  String weight, price;
  bool _isfetchingnew = false;
  final formKey = new GlobalKey<FormState>();
  String nextOrderURL;
  List _suggested = [];
  List _cities = [];
  List _contacts = [];

  loadMycontacts() {
    if (Provider.of<ContactsGroups>(context, listen: true).contacts.isEmpty) {
      Provider.of<ContactsGroups>(context, listen: true).fetchAndSetMyContacts(widget.token);
    }
  }
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override //todo: check for future
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // FutureOr<Iterable> getSuggestions(String pattern) async {
  //   String url = "https://briddgy.herokuapp.com/api/cities/?search=" + pattern;
  //   await http.get(
  //     url,
  //     headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
  //   ).then((response) {
  //     setState(
  //       () {
  //         final dataOrders = json.decode(response.body) as Map<String, dynamic>;
  //         _suggested = dataOrders["results"];
  //         // isLoading = false;
  //       },
  //     );
  //   });
  //   _cities = [];
  //   for (var i = 0; i < _suggested.length; i++) {
  //     _cities.add(_suggested[i]["city_ascii"].toString() +
  //         ", " +
  //         _suggested[i]["country"].toString() +
  //         ", " +
  //         _suggested[i]["id"].toString());
  //   }
  //   return _cities;
  // }

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
                "Contacts",
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
                    FilterBar(),
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
                                    print("load order");
                                  });
                                  _loadData();
                                }
                              },
                              child: ListView.builder(
                                itemBuilder: (context, int i) {
                                  return InkWell(
                                    onTap: () {},
                                    child: Container(
                                      height: 130,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Card(
                                        elevation: 4,
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                child: Image(
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent
                                                              loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes
                                                            : null,
                                                      ),
                                                    );
                                                  },

                                                  image: NetworkImage(
                                                      // "https://briddgy.herokuapp.com/media/" + _user["avatarpic"].toString() +"/"
                                                      "https://picsum.photos/250?image=9"), //Todo,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 200,
                                                    child: Text(
//                                                    _contacts[i]["title"].toString().length > 20
//                                                        ? _contacts[i]["title"].toString().substring(0, 20) + "..."
//                                                        :
                                                      _contacts[i]["username"]
                                                          .toString(), //Todo: title
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.grey[800],
//                                          fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Icon(
                                                        MdiIcons
                                                            .mapMarkerMultipleOutline,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      SizedBox(
                                                        width: 200,
                                                        child: Text(
                                                          _contacts[i]["first_name"]
                                                          .toString() +" "+_contacts[i]["last_name"]
                                                          .toString(),
                                                          //Todo: Source -> Destination
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
//                                                   Row(
// //                                        mainAxisSize: MainAxisSize.max,
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceAround,
//                                                     children: <Widget>[
//                                                       Row(
//                                                         children: <Widget>[
//                                                           Icon(
//                                                             MdiIcons
//                                                                 .calendarRange,
//                                                             color: Theme.of(
//                                                                     context)
//                                                                 .primaryColor,
//                                                           ),
//                                                           Text(
//                                                             _contacts[i]["date"]
//                                                                 .toString(),
//                                                             //Todo: date
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .grey[600]),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       SizedBox(
//                                                         width: 50,
//                                                       ),
//                                                     ],
//                                                   ),
                                             
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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
