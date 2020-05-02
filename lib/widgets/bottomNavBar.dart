import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget bottomNavBar() {
  return BottomNavigationBar(
    currentIndex: 0, // this will be set when a new tab is tapped

    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Colors.grey),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.location_on, color: Colors.blue),
        title: new Text(
          'Map',
          style: TextStyle(color: Colors.blue),
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
  );
}
