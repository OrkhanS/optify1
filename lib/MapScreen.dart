import 'package:flutter/material.dart';

void main() => runApp(MapScreen());

class MapScreen extends StatefulWidget {
  MapScreenMain createState() => MapScreenMain();
}

class MapScreenMain extends State<MapScreen> {
  final appBar = AppBar(
    title: Text('Map'),
    backgroundColor: Colors.blue[600],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        /*bottomNavigationBar: bottomNavBar(),*/
        body:
            /*GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(25.334206, 55.388947),
            zoom: 2.0,
          ),
          mapType: MapType.normal,
        ),*/
            Column(children: <Widget>[
          new Expanded(
            child: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('Assets/maptemporary.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
