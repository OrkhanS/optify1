import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/screens/add_item_screen.dart';
import 'package:optifyapp/screens/add_trip_screen.dart';
import 'package:optifyapp/screens/my_trips.dart';
import 'package:optifyapp/screens/trip_screen.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import 'package:flutter/foundation.dart';
import './screens/account_screen.dart';
import './screens/notification_screen.dart';
import './screens/chats_screen.dart';
import './screens/chat_window.dart';
import 'package:optifyapp/screens/profile_screen.dart';
import 'package:optifyapp/screens/item_screen.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:web_socket_channel/io.dart';
import 'package:optifyapp/providers/messages.dart';
import 'package:optifyapp/providers/ordersandtrips.dart';
import 'package:optifyapp/screens/my_items.dart';
import 'package:optifyapp/screens/contracts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/screens/auth_screen.dart';

import 'package:optifyapp/screens/schedule_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final StreamController<String> streamController = StreamController<String>.broadcast();
  IOWebSocketChannel _channel;
  ObserverList<Function> _listeners = new ObserverList<Function>();
  var button = ChatsScreen();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _isOn = false;
  int _currentIndex = 0;
  PageController _pageController;
  String tokenforROOM;
  Map valueMessages = {};
  bool socketConnected = false;
  var neWMessage;

  @override
  void initState() {
    _currentIndex = 0;
    super.initState();
    getToken();
    _pageController = PageController(initialPage: 0);
  }

  _configureFirebaseListerners(newmessage) {
    _firebaseMessaging.configure(
      // onMessage: (Map<String, dynamic> message) async {
      //   neWMessage.addMessages = message;
      // },
      onLaunch: (Map<String, dynamic> message) async {
        neWMessage.addMessages = message;
      },
      onResume: (Map<String, dynamic> message) async {
        neWMessage.addMessages = message;
      },
    );
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsScreen()),
      );

  initCommunication(auth, newmessage) async {
    if (socketConnected == false) {
      socketConnected = true;
      reset();
      try {
        var f, d;
        auth.removeListener(f);
        newmessage.removeListener(d);
        neWMessage = newmessage;
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('userData')) {
          return false;
        }
        final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

        auth.token = extractedUserData['token'];

        if (extractedUserData['token'] != null) {
          widget._channel = new IOWebSocketChannel.connect('ws://briddgy.herokuapp.com/ws/alert/?token=' + extractedUserData['token']);
          widget._channel.stream.listen(_onReceptionOfMessageFromServer);
          print("Alert Connected");
        }
      } catch (e) {
        print("Error Occured");
        reset();
      }
    } else {
      return;
    }
  }

  /// ----------------------------------------------------------
  /// Closes the WebSocket communication
  /// ----------------------------------------------------------
  reset() {
    if (widget._channel != null) {
      if (widget._channel.sink != null) {
        widget._channel.sink.close();
        _isOn = false;
      }
    }
  }

  addListener(Function callback) {
    widget._listeners.add(callback);
  }

  removeListener(Function callback) {
    widget._listeners.remove(callback);
  }

  _onReceptionOfMessageFromServer(message) {
    valueMessages = json.decode(message);
    neWMessage.addMessages = valueMessages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget navbar(newmessage) {
    return BottomNavigationBar(
      elevation: 4,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.lightGreenAccent[600],
      unselectedItemColor: Colors.grey[400],
      unselectedFontSize: 9,
      selectedFontSize: 11,
      onTap: (index) {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Text('Schedule'),
          icon: Icon(MdiIcons.mapClockOutline),
          activeIcon: Icon(MdiIcons.mapClock),
        ),
        BottomNavigationBarItem(
          title: Text('Social'),
          icon: Icon(MdiIcons.accountGroupOutline),
          activeIcon: Icon(MdiIcons.accountGroup),
        ),
        BottomNavigationBarItem(
          title: Text('Profile'),
//          icon: newmessage.arethereNewMessage == true
//              ? Badge(
//                  child: Icon(MdiIcons.forumOutline),
//                )
//              :
          icon: Icon(MdiIcons.accountTieOutline),
          activeIcon: Icon(MdiIcons.accountTie),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          builder: (_) => OrdersTripsProvider(),
        ),
        ChangeNotifierProvider(
          builder: (_) => Messages(),
        ),
      ],
      child: Consumer3<Auth, Messages, OrdersTripsProvider>(builder: (
        ctx,
        auth,
        newmessage,
        orderstripsProvider,
        _,
      ) {
        newmessage.fetchAndSetRooms(auth);
        initCommunication(auth, newmessage);
        _configureFirebaseListerners(newmessage);
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.lightGreen,
            primaryColor: Colors.lightGreen[900],
            accentColor: Colors.lightGreenAccent,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? Scaffold(
                  body: SizedBox.expand(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      children: <Widget>[
                        ScheduleScreen(),
                        ScheduleScreen(),
//                  OrdersScreen(orderstripsProvider: orderstripsProvider, room: newmessage, auth: auth, token: tokenforROOM),
//                  TripsScreen(orderstripsProvider: orderstripsProvider, room: newmessage, auth: auth, token: tokenforROOM),
//                  ChatsScreen(provider: newmessage, auth: auth, token: tokenforROOM),
//                  NotificationScreen(),
                        AccountScreen(token: tokenforROOM, auth: auth, orderstripsProvider: orderstripsProvider),
                      ],
                    ),
                  ),
                  bottomNavigationBar: navbar(newmessage),
                )
              : AuthScreen(),
          routes: {
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            TripsScreen.routeName: (ctx) => TripsScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            ItemScreen.routeName: (ctx) => ItemScreen(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
            AddTripScreen.routeName: (ctx) => AddTripScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            MyItems.routeName: (ctx) => MyItems(),
            MyTrips.routeName: (ctx) => MyTrips(),
            Contracts.routeName: (ctx) => Contracts(),
            AccountScreen.routeName: (ctx) => AccountScreen(token: tokenforROOM, orderstripsProvider: orderstripsProvider),
          },
        );
      }),
    );
  }
}
