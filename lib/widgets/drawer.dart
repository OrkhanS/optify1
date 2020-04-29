import 'package:flutter/material.dart';
import 'package:optifyapp/members.dart';
import 'package:optifyapp/MainProfile.dart';
import 'package:optifyapp/MainMap.dart';
import 'package:optifyapp/ActivityListScreen.dart';
import 'package:optifyapp/StatsScreen.dart';

Widget drawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
            children: <Widget>[
              Text(
                'Kazato Suriname',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Container(
                height: 100,
                child: Image.network('https://pixls.us/articles/faces-of-open-source/Brian_Kernighan_by_Peter_Adams_w640.jpg'),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(Icons.face),
          title: Text('Profile'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainProfile()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_today),
          title: Text('Schedule'),
          onTap: () {
//            Navigator.push(context, MaterialPageRoute(builder: (context) => MainSchedule()));
            //Navigator.pop(context);
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.location_on),
          title: Text('Map'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainMap()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.graphic_eq),
          title: Text('Statistics'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.contacts),
          title: Text('Contacts'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MemberPage()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.group),
          title: Text('Groups'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Activites'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityListScreen()));
            // Update the state of the app.
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Update the state of the app.
            // ...
          },
        ),
      ],
    ),
  );
}
