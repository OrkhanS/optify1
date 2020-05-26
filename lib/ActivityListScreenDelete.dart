import 'dart:convert';
import 'dart:io';
import 'widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/activityListElement.dart';
import 'routes.dart';
import 'NewActivityMain.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';

void main() => runApp(ActivityListScreen());

class Activity {
  String id;
  String title;
  String start_times;
  String end_times;
  String recurring;
  String repetition;
  String priority;
  String privacy;
  Activity(this.end_times, this.priority, this.privacy, this.recurring, this.repetition, this.start_times, this.title, this.id);

  Activity.fromJson(Map<String, dynamic> json) {
    title = json["activity"]["title"].toString();
    start_times = json["activity"]["start_times"].toString();
    end_times = json["activity"]["end_times"].toString();
    recurring = json["activity"]["recurring"].toString();
    repetition = json["activity"]["repetition"].toString();
    priority = json["priority"].toString();
    privacy = json["privacy"].toString();
    id = json["activity"]["id"].toString();
  }
}

class ActivityListScreen extends StatefulWidget {
  @override
  ActivityListScreenState createState() => ActivityListScreenState();
}

class ActivityListScreenState extends State<ActivityListScreen> {
  final List<Activity> _activity = List<Activity>();

  Future<List<Activity>> fetchActivities() async {
    var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
    const url1 = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/';
    http.Response response = await http.get(
      url1,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );
    var activity = List<Activity>();

    if (response.statusCode == 200) {
      var ActivityForAdd = json.decode(response.body);
      for (var ActivityJson in ActivityForAdd) {
        activity.add(Activity.fromJson(ActivityJson));
      }
    }

    return activity;
  }

  @override
  void initState() {
    fetchActivities().then((value) {
      setState(() {
        _activity.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Activity List';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        drawer: drawer(context),
        floatingActionButton: AnimatedFloatingActionButton(
            //Fab list
            fabButtons: <Widget>[float1(context), float2()],
            colorStartAnimation: Colors.blue,
            colorEndAnimation: Colors.red,
            animatedIconData: AnimatedIcons.menu_close //To principal button
            ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(

            //final item = _activity[index];

            children: <Widget>[
              for (int i = _activity.length - 1; i >= 0; i--)
                Dismissible(
                    // Each Dismissible must contain a Key. Keys allow Flutter to
                    // uniquely identify widgets.
                    key: Key(_activity[i].id),
                    // Provide a function that tells the app
                    // what to do after an item has been swiped away.
                    onDismissed: (direction) {
                      // Remove the item from the data source.
                      setState(() {
                        var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
                        var url2 = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/' + _activity[i].id.toString() + '/';
                        print(url2);
                        http.delete(
                          url2,
                          headers: {
                            HttpHeaders.CONTENT_TYPE: "application/json",
                            "Authorization": "Token " + token,
                          },
                        ).then((response) {
                          print(response.body);
                        });
                      });
                      _activity.removeAt(i);

                      // Then show a snackbar.
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(" dismissed")));
                    },
                    // Show a red background as the item is swiped away.
                    background: Container(color: Colors.red),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      elevation: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                              height: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _activity[i].title,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text('Time: ' + _activity[i].start_times.substring(12, 17) + " - " + _activity[i].end_times.substring(12, 17)),
                                  Text('Priority: ' + _activity[i].priority),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              height: 80,
                              child: Image.network('https://www.nhs-health-trainers.co.uk/wp-content/uploads/2019/05/physical-activity.jpg'),
                            ),
                          ),
                        ],
                      ),
                    ))
            ]),
      ),
    );
  }
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      drawer: drawer(context),
//      floatingActionButton: AnimatedFloatingActionButton(
//          //Fab list
//          fabButtons: <Widget>[float1(context), float2()],
//          colorStartAnimation: Colors.blue,
//          colorEndAnimation: Colors.red,
//          animatedIconData: AnimatedIcons.menu_close //To principal button
//          ),
//      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//      appBar: AppBar(
//        title: Text('Activity List'),
//      ),
//      body: ListView(
//        children: <Widget>[
//          for (var i = _activity.length - 1; i >= 0; i--)
//            Card(
//              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
//              elevation: 5,
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Flexible(
//                    child: Container(
//                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
//                      height: 100,
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text(
//                            _activity[i].title,
//                            style: TextStyle(
//                              fontSize: 20,
//                            ),
//                          ),
//                          Text('Time: ' +
//                              _activity[i].start_times.substring(12, 17) +
//                              " - " +
//                              _activity[i].end_times.substring(12, 17)),
//                          Text('Priority: ' + _activity[i].priority),
//                        ],
//                      ),
//                    ),
//                  ),
//                  Flexible(
//                    child: Container(
//                      height: 80,
//                      child: Image.network(
//                          'https://www.nhs-health-trainers.co.uk/wp-content/uploads/2019/05/physical-activity.jpg'),
//                    ),
//                  ),
//                ],
//              ),
//            )
//        ],
//      ),
//    );
//  }
}

Widget float1(context) {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn1",
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewActivityPage()));
      },
      tooltip: 'First button',
      child: Icon(Icons.add),
    ),
  );
}

Widget float2() {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn2",
      onPressed: null,
      tooltip: 'Second button',
      child: Icon(Icons.edit),
    ),
  );
}
