import 'package:flutter/material.dart';
import 'package:optifyapp/widgets/bottomNavBar.dart';
import 'widgets/drawer.dart';
import 'package:optifyapp/widgets/activityListElement.dart';
import 'widgets/activityBox.dart';
import 'ActivityListScreen.dart';
import 'package:pie_chart/pie_chart.dart';

void main() => runApp(StatsScreen());

class StatsScreen extends StatelessWidget {
  final appBar = AppBar(
    title: Text('Statistics'),
    backgroundColor: Colors.blue[600],
  );

  Widget build(BuildContext context) {


    //sleep(const Duration(seconds: 10));
    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        drawer: drawer(context),
        //bottomNavigationBar: bottomNavBar(),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
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
                    Container(
                      padding: EdgeInsets.all(10),
                      height: 150,
                      child: Image.network(
                          'https://pixls.us/articles/faces-of-open-source/Brian_Kernighan_by_Peter_Adams_w640.jpg'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "Statistics",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              PieChart(dataMap: dataMap),
            ],
          ),
        ),
      ),
    );
  }
}
