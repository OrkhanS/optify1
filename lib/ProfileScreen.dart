import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:http/http.dart' as http;
import 'widgets/drawer.dart';
import 'widgets/drawActivity.dart';

void main() => runApp(ProfileScreen());

class ProfileScreen extends StatelessWidget {
  final appBar = AppBar(
    title: Text('My Profile'),
    backgroundColor: Colors.blue[600],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        drawer: drawer(context),
        /*bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // this will be set when a new tab is tapped

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.blue),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.location_on, color: Colors.grey),
              title: new Text(
                'Map',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.date_range,
              ),
              title: new Text(
                'Schedule',
              ),
            ),
          ],
        ),*/
        body: Container(

          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 150,
                      child: Image.network(
                          'https://pixls.us/articles/faces-of-open-source/Brian_Kernighan_by_Peter_Adams_w640.jpg'),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Kazato Suriname",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text("Painter, I like dogs")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.pie_chart,
                        color: Colors.blue.shade800,
                        size: 35,
                      ),
                      Text(
                        'Stats',
                        style: TextStyle(color: Colors.blue.shade800),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.blue.shade800,
                        size: 35,
                      ),
                      Text(
                        'Map',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Colors.blue.shade800,
                        size: 35,
                      ),
                      Text(
                        'Schedule',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 200,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.blue.shade100),
                child: ListTile(
                  title: Center(child: Text('Contacts: 10')),
                ),
              ),
              Container(
                width: 200,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.blue.shade100),
                child: ListTile(
                  title: Center(child: Text('Groups: 2')),
                ),
              ),
              Container(
                width: 200,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.blue.shade100),
                child: ListTile(
                  title: Center(child: Text('Events: 3')),
                ),
              ),
            /*  Container(
                width: 200,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.blue.shade100),
                child: ListTile(
                  title: Center(child: Text('Locations: 2')),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
