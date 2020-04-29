import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:http/http.dart' as http;
import '../widgets/drawer.dart';
import '../widgets/activityBox.dart';
import 'package:optifyapp/ActivityClass.dart';
import 'package:optifyapp/newActivityMain.dart';

void main() => runApp(ScheduleScreen());

class ScheduleScreen extends StatefulWidget {
  ScheduleScreenMain createState() => ScheduleScreenMain();
}

class ScheduleScreenMain extends State<ScheduleScreen> {
  List<Activity> _activity = List<Activity>();

  Future<List<Activity>> fetchActivities() async {
    var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
    const url = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/';
    http.Response response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );

    var activity = List<Activity>();

    if (response.statusCode == 200) {
      var ActivityForAdd = json.decode(response.body);
      for (var ActivityJson in ActivityForAdd) {
        var some = Activity.fromJson(ActivityJson);
        activity.add(some);
      }
    }
    /*for (var x in activity){
        dataMap.putIfAbsent(x.title,  () => double.parse(x.duration));
      }*/

    return activity;
  }

  @override
  void initState() {
    // fetchActivities().then((value) {
    //   setState(() {
    //     _activity.addAll(value);
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var nowWeekday = now.weekday;
    var ayble;
    var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
    const url = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/';
    http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    ).then((response) {
//      ayble = json.decode(response.body);
//      print(json.decode(response.body));
//      print(ayble[0]["activity"]["start_times"].toString().substring(1,11)+' '+ayble[0]["activity"]["start_times"].toString().substring(12,20));
//      DateTime date = DateTime.parse(ayble[0]["activity"]["start_times"].toString().substring(1,11)+' '+ayble[0]["activity"]["start_times"].toString().substring(12,20));
//      print("weekday is ${date.weekday}");
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Schedule",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      floatingActionButton: AnimatedFloatingActionButton(
          //Fab list
          fabButtons: <Widget>[float1(context), float2()],
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close //To principal button
          ),
//        floatingActionButton: AnimatedFloatingActionButton(
//          onPressed: () {},
//          tooltip: 'Add',
//          child: AnimatedIcon(
//            icon: AnimatedIcons.event_add,
//            progress: null,
//          ),
//        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2.0,
                          color: Colors.grey[100],
                        ),
                        right: BorderSide(
                          width: 2.0,
                          color: Colors.grey[100],
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "May", //todo: Month
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "10 - 17", //todo :Range
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  weekDay(day: "Mon"),
                  weekDay(day: "Tue"),
                  weekDay(day: "Wed"),
                  weekDay(day: "Thu"),
                  weekDay(day: "Fri"),
                  weekDay(day: "Sat"),
                  weekDay(day: "Sun"),
                ],
              ),
              FullTime(
                activityList: _activity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullTime extends StatefulWidget {
  final List<Activity> activityList;
  FullTime({Key key, @required this.activityList}) : super(key: key);

  @override
  FullTimeState createState() => FullTimeState();
}

class FullTimeState extends State<FullTime> {
  double scaleHeight = 80;
  double check = 80;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          check = ((scaleHeight * sqrt(sqrt(sqrt(sqrt(scaleDetails.scale))))).round()).toDouble();
          if (check > 50 && check < 150) {
            setState(() {
              scaleHeight = check;
            });
          } else {
            check = scaleHeight;
          }
        },
        child: Container(
          child: ListView(
            children: [
              Stack(children: [
                Column(
                  children: <Widget>[
                    for (var i = 8; i < 24; i++)
                      if (i > 9)
                        hourRow(time: "${i.toString()}:00", vertical: scaleHeight)
                      else
                        hourRow(time: "0${i.toString()}:00", vertical: scaleHeight)
                  ],
                ),
                for (var x in widget.activityList) activityBoxObject(x, scaleHeight / 60),
//                activityBox(
//                    height: scaleHeight / 60,
//                    duration: 120,
//                    days: 5,
//                    starttime: 19,
//                    startday: 1, //1 - monday, 5 friday
//                    name: "Work",
//                    description: "Workout at gym"),
//                activityBox(
//                    height: scaleHeight / 60,
//                    duration: 180,
//                    days: 5,
//                    starttime: 14,
//                    startday: 1, //1 - monday, 5 friday
//                    name: "Work",
//                    description: "Workout at gym"),
//                activityBox(
//                    height: scaleHeight / 60,
//                    duration: 90,
//                    days: 4,
//                    starttime: 17,
//                    startday: 3, //1 - monday, 5 friday
//                    name: "Gym",
//                    description: "Workout at gym"),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

Widget weekDay({@required final String day}) {
  return Expanded(
    flex: 1,
    child: Container(
      height: 50,
      width: 47,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 2.0, color: Colors.grey[100]),
          right: BorderSide(width: 2.0, color: Colors.grey[100]),
          top: BorderSide(width: 2.0, color: Colors.grey[100]),
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(fontSize: 15),
        ),
      ),
    ),
  );
}

Widget hourRow({@required final String time, @required final double vertical}) {
  return Container(
    decoration: BoxDecoration(
      border: const Border(
        bottom: const BorderSide(
          width: 1.0,
          color: Color(0xFFE0E0E0),
        ),
      ),
    ),
    child: Row(
      children: [
        Container(
          height: vertical,
          width: 50,
          decoration: BoxDecoration(
            border: const Border(
              right: const BorderSide(
                width: 1.0,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ),
          child: Center(
            child: Text(time),
          ),
        ),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
        placeHolder(vertical: vertical),
      ],
    ),
  );
}

Widget placeHolder({@required double vertical}) {
  return Expanded(
      child: Container(
    height: vertical,
    decoration: const BoxDecoration(
      border: const Border(
        right: const BorderSide(
          width: 1.0,
          color: Color(0xFFE0E0E0),
        ),
      ),
    ),
  ));
}

Widget float1(context) {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn1",
      onPressed: () {
        navigateToAddActivity(context);
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

void navigateToAddActivity(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => NewActivityPage()));
}
