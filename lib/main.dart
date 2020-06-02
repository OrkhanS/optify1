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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/screens/auth_screen.dart';

import 'package:optifyapp/screens/schedule_screen.dart';
import 'package:optifyapp/screens/social_screen.dart';
import 'package:optifyapp/screens/contacts_screen.dart';
import 'package:optifyapp/providers/activities.dart';

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
  String schedule_id;
  @override
  void initState() {
    super.initState();
    getToken();
  }

  _configureFirebaseListerners(newmessage) {
    // _firebaseMessaging.configure(
    //   // onMessage: (Map<String, dynamic> message) async {
    //   //   neWMessage.addMessages = message;
    //   // },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     neWMessage.addMessages = message;
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     neWMessage.addMessages = message;
    //   },
    // );
  }

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
    getscheduleId();
  }

  Future getscheduleId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('scheduleData')) {
      return false;
    }
    final extractedscheduleData = json.decode(prefs.getString('scheduleData')) as Map<String, Object>;
    schedule_id = extractedscheduleData['schedule_id'];
  }

  Future onSelectNotification(String payload) async => await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsScreen()),
      );

//  initCommunication(auth, newmessage) async {
//    if (socketConnected == false) {
//      socketConnected = true;
//      reset();
//      try {
//        var f, d;
//        auth.removeListener(f);
//        newmessage.removeListener(d);
//        neWMessage = newmessage;
//        final prefs = await SharedPreferences.getInstance();
//        if (!prefs.containsKey('userData')) {
//          return false;
//        }
//        final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
//
//        auth.token = extractedUserData['token'];
//
//        // if (extractedUserData['token'] != null) {
//        //   widget._channel = new IOWebSocketChannel.connect('ws://briddgy.herokuapp.com/ws/alert/?token=' + extractedUserData['token']);
//        //   widget._channel.stream.listen(_onReceptionOfMessageFromServer);
//        //   print("Alert Connected");
//        // }
//      } catch (e) {
//        print("Error Occured");
//        reset();
//      }
//    } else {
//      return;
//    }
//  }

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
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Text('Schedule'),
          icon: Icon(MdiIcons.mapClockOutline),
          activeIcon: Icon(MdiIcons.mapClock),
        ),
        BottomNavigationBarItem(
          title: Text('People'),
          icon: Icon(MdiIcons.accountGroupOutline),
          activeIcon: Icon(MdiIcons.accountGroup),
        ),
        BottomNavigationBarItem(
          title: Text('Chats'),
          icon: Icon(MdiIcons.forumOutline),
          activeIcon: Icon(MdiIcons.forum),
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

  static List<Widget> currentScreen = [ScheduleScreen(), SocialScreen(), SocialScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          builder: (_) => Activities(),
        ),
        ChangeNotifierProvider(
          builder: (_) => Messages(),
        ),
      ],
      child: Consumer3<Auth, Messages, Activities>(builder: (
        ctx,
        auth,
        newmessage,
        activitiesProvider,
        _,
      ) {
        // newmessage.fetchAndSetRooms(auth);
        // initCommunication(auth, newmessage);
        // _configureFirebaseListerners(newmessage);

        auth.isAuth == false ? auth.tryAutoLogin() : auth.isAuth;
        activitiesProvider.isLoadingActivities == true
            ? activitiesProvider.fetchAndSetMyActivities(tokenforROOM, schedule_id)
            : activitiesProvider.activities;
//        auth.fetchAndSetUserDetails();
        if (auth.isAuth) auth.fetchAndSetUserDetails();
        return MaterialApp(
          title: 'Optisend',
          theme: ThemeData(
            primarySwatch: Colors.lightGreen,
            primaryColor: Colors.lightGreen[900],
            accentColor: Colors.lightGreenAccent,
            fontFamily: 'Lato',
          ),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
          home: auth.isAuth
              ? SafeArea(
                  child: Scaffold(
                    bottomNavigationBar: navbar(newmessage),
                    body: currentScreen[_currentIndex],
                  ),
                )
              : AuthScreen(),
          routes: {
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            TripsScreen.routeName: (ctx) => TripsScreen(),
            ChatsScreen.routeName: (ctx) => ChatsScreen(),
            ChatWindow.routeName: (ctx) => ChatWindow(),
            ItemScreen.routeName: (ctx) => ItemScreen(),
            AddItemScreen.routeName: (ctx) => AddItemScreen(),
            AddTripScreen.routeName: (ctx) => AddTripScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            MyItems.routeName: (ctx) => MyItems(),
            MyTrips.routeName: (ctx) => MyTrips(),
            AccountScreen.routeName: (ctx) => AccountScreen(token: tokenforROOM, orderstripsProvider: activitiesProvider),
            SocialScreen.routeName: (ctx) => SocialScreen(),
            ContactsScreen.routeName: (ctx) => ContactsScreen(),
          },
        );
      }),
    );
  }
}
