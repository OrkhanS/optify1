import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:optifyapp/widgets/bottomNavBar.dart';
import 'widgets/drawer.dart';
import 'screens/schedule_screen.dart';
import 'package:optifyapp/ProfileScreen.dart';
import 'MapScreen.dart';

void main() => runApp(MainProfile());

class MainProfile extends StatefulWidget {
  MainProfileMain createState() => MainProfileMain();
}

class MainProfileMain extends State<MainProfile> {
  int _selectedPage = 0;
  final _page = [ProfileScreen(), MapScreen(), ScheduleScreen()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage, // this will be set when a new tab is tapped
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile')),
            BottomNavigationBarItem(
              icon: new Icon(Icons.location_on),
              title: new Text('Map'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.date_range),
              title: new Text('Schedule'),
            )
          ],
        ),
        body: _page[_selectedPage],
      ),
    );
  }
}
