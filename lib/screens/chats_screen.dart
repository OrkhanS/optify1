import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:menu/menu.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:optifyapp/screens/chat_window.dart';
import 'package:optifyapp/screens/profile_screen_another.dart';
import 'package:optifyapp/screens/report_user_screen.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'chat_window.dart';
import 'package:optifyapp/providers/messages.dart';
import 'dart:async';
import 'package:badges/badges.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsScreen extends StatefulWidget {
  static const routeName = '/chat';
  final StreamController<String> streamController = StreamController<String>.broadcast();
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  PageController pageController;
  int numberOfPages = 6;
  double viewportFraction = 0.75;
  String imageUrl;
  bool isMessagesLoaded = false;
  Future<int> roomLength;
  List _rooms = [];
  String myid, secondId;
  bool _isfetchingnew = false;
  String nextMessagesURL = "FirstCall";
  var messageProvider, auth;
  bool a= false;
  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(auth == null){
      messageProvider = Provider.of<Messages>(context);
      auth = Provider.of<Auth>(context);
      myid = auth.myUserId;
    }
  

    List<MaterialColor> colors = [
      Colors.amber,
      Colors.red,
      Colors.green,
      Colors.lightBlue,
    ];

    Future _loadData() async {
      if (nextMessagesURL.toString() != "null") {
        String url = nextMessagesURL;
        try {
          await http.get(
            url,
            headers: {
              HttpHeaders.CONTENT_TYPE: "application/json",
              "Authorization": "Token " + auth.myToken,
            },
          ).then((response) {
            var dataOrders = json.decode(response.body) as Map<String, dynamic>;
            _rooms.addAll(dataOrders["results"]);
            nextMessagesURL = dataOrders["next"];
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

    return Consumer<Messages>(
      builder: (context, messageProvider, child) {
        if (messageProvider.chats.length != 0) {
          _rooms = messageProvider.allChatRoomDetails["results"];
         
          if (nextMessagesURL == "FirstCall") {
            nextMessagesURL = messageProvider.allChatRoomDetails["next"];
          }
          //messageLoader = false;
        } else {
          //messageLoader = true;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                "Chats",
                style: TextStyle(color: (Theme.of(context).primaryColor), fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 1,
          ),
          body: Container(
            child:messageProvider.isChatsLoading == true 
                ? Center(child: CircularProgressIndicator())
                : messageProvider.chats == null || messageProvider.chats.length == 0
                    ? Center(child: Text('No Chats'))
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
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                itemCount: _rooms.length,
                                itemBuilder: (context, int index) {
                                   if(_rooms[index]["members"][0]["user"]["id"].toString() == myid.toString()){
                                      secondId = _rooms[index]["members"][1]["user"]["id"].toString();
                                  }else{
                                      secondId = _rooms[index]["members"][0]["user"]["id"].toString();
                                  }
                                  return Column(
                                    children: <Widget>[
                                      Divider(
                                        height: 12.0,
                                      ),
                                      Menu(
                                        child: Container(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              // Todo
                                              // Warning
                                              // Warning
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                    radius: 24.0,
                                                    child: Image(
                                                    image: NetworkImage(
                                                         "https://robohash.org/" + secondId.toString()),
                                                    height: 80,
                                                    width: 90,
                                                  ),
                                                    ),
                                                title: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      _rooms[index]["members"][1]["user"]["id"].toString() != myid
                                                          ? _rooms[index]["members"][1]["user"]["first_name"].toString() +
                                                              " " +
                                                              _rooms[index]["members"][1]["user"]["last_name"].toString()
                                                          : _rooms[index]["members"][0]["user"]["first_name"].toString() +
                                                              " " +
                                                              _rooms[index]["members"][0]["user"]["last_name"].toString(),
                                                      style: TextStyle(fontSize: 15.0),
                                                    ),
                                                    SizedBox(
                                                      width: 16.0,
                                                    ),
                                                    // Text(
                                                    //   _rooms[index]["date_modified"]
                                                    //       .toString()
                                                    //       .substring(0, 10),
                                                    //   style: TextStyle(fontSize: 15.0),
                                                    // ),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Last Message:" + "  ",
                                                      style: TextStyle(fontSize: 15.0),
                                                      // _messages[index]["results"][0]["text"]
                                                      //   .toString().substring(0,15)
                                                    ),
                                                    Text(
                                                      // timeago.format(DateTime.parse(_rooms[index]["date_modified"].toString().substring(0, 10) + " " + _rooms[index]["date_modified"].toString().substring(11, 26))).toString().substring(0, 1) == "3" ||
                                                      //         timeago.format(DateTime.parse(_rooms[index]["date_modified"].toString().substring(0, 10) + " " + _rooms[index]["date_modified"].toString().substring(11, 26))).toString().substring(0, 1) ==
                                                      //             "2"
                                                      //     ? "Recently"
                                                      //     :
                                                      timeago
                                                          .format(DateTime.parse(_rooms[index]["date_modified"].toString().substring(0, 10) +
                                                              " " +
                                                              _rooms[index]["date_modified"].toString().substring(11, 26)))
                                                          .toString(),
                                                      style: TextStyle(fontSize: 15.0),
                                                    )
                                                  ],
                                                ),
                                                trailing: messageProvider.newMessages[_rooms[index]["id"]].toString() != "0" &&
                                                        messageProvider.newMessages[_rooms[index]["id"]].toString() != "null"
                                                    ? Badge(
                                                        badgeContent: Text(messageProvider.newMessages[_rooms[index]["id"]].toString()),
                                                        child: Icon(Icons.arrow_forward_ios),
                                                      )
                                                    : Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 14.0,
                                                      ),
                                                onTap: () {
                                                  messageProvider.readMessages(_rooms[index]["id"]);
                                                  Provider.of<Messages>(context).newMessage[_rooms[index]["id"]] = 0;
                                                  messageProvider.fetchAndSetMessages(index, auth);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (__) => ChatWindow(
                                                            provider: messageProvider,
                                                            room: _rooms[index]["id"],
                                                            user: _rooms[index]["members"][1]["user"]["id"].toString() != myid
                                                                ? _rooms[index]["members"][1]["user"]
                                                                : _rooms[index]["members"][0]["user"],
                                                            auth: auth)),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        items: [
                                          MenuItem(
                                            "Profile",
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (__) => ProfileScreenAnother(
                                                          user: _rooms[index]["members"][1]["user"]["id"].toString() != myid
                                                              ? _rooms[index]["members"][1]["user"]
                                                              : _rooms[index]["members"][0]["user"],
                                                        )),
                                              );
                                            },
                                          ),
                                          MenuItem("Info", () {
                                            Alert(
                                              context: context,
                                              type: AlertType.info,
                                              title: "Conversation started on:  " + _rooms[index]["date_created"].toString().substring(0, 10) + "\n",
                                              buttons: [
                                                DialogButton(
                                                  child: Text(
                                                    "Back",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => Navigator.pop(context),
                                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                                ),
                                                DialogButton(
                                                  child: Text(
                                                    "Report",
                                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                                  ),
                                                  onPressed: () => {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (__) => ReportUser(
                                                                user: _rooms[index]["members"],
                                                                message: null,
                                                              )),
                                                    ),
                                                  },
                                                  color: Color.fromRGBO(0, 179, 134, 1.0),
                                                )
                                              ],
                                              content: Text(
                                                  "To keep our community more secure and as mentioned in our Privacy&Policy, you cannot remove chats.\n"),
                                            ).show();
                                          }),
                                        ],
                                        decoration: MenuDecoration(),
                                      ),
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
          ),
        );
      },
    );
  }
}
