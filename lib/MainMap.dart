import 'package:flutter/material.dart';
import 'screens/schedule_screen.dart';
import 'package:optifyapp/ProfileScreen.dart';
import 'MapScreen.dart';

void main() => runApp(MainMap());

class MainMap extends StatefulWidget {
  MainMapMain createState() => MainMapMain();
}

class MainMapMain extends State<MainMap> {
  int _selectedPage = 1;
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
