import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/ActivityListScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'routes.dart';

void main() => runApp(MaterialApp(
      home: ActivityAI(),
    ));

class ActivityAI extends StatefulWidget {
  ActivityAIPage createState() => ActivityAIPage();
}

class ActivityAIPage extends State<ActivityAI> {
  static String _ActivityName, _start_times, _end_times;
  int _currentValue = 1;
  double _discreteValue = 10.0;
  DateTime _dateTimeStart, _dateTimeEnd;
  var snackBar;
  TimeOfDay _timeStart, _timeEnd;
  var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
  Duration _duration;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final appBar = AppBar(
    title: Text('AI Scheduler'),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: FormUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget FormUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15),
            child: SizedBox(
              height: 80.0,
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    height: 60,
                    minWidth: 130,
                    padding: EdgeInsets.all(8.0),
                    child: Text('Start Date'),
                    color: Colors.white,
                    onPressed: () {
                      showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                        _timeStart = time;
                      });
                      showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2222)).then((date) {
                        _dateTimeStart = date;
                      });
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15.0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      height: 60,
                      minWidth: 130,
                      padding: EdgeInsets.all(8.0),
                      child: Text('End Date'),
                      color: Colors.white,
                      onPressed: () {
                        showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                          _timeEnd = time;
                        });
                        showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2222))
                            .then((date) {
                          _dateTimeEnd = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                  height: 200,
                  child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: Duration.zero,
                      minuteInterval: 1,
                      secondInterval: 1,
                      onTimerDurationChanged: (time) {
                        setState(() {
                          _duration = time;
                        });
                      }))
            ],
          ),
          Container(
              width: 50.0,
              height: 50.0,
              child: FloatingActionButton(
                tooltip: 'Save',
                child: Icon(Icons.add),
                onPressed: () {
                  const url = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/ai/';
                  http
                      .post(url,
                          headers: {
                            HttpHeaders.CONTENT_TYPE: "application/json",
                            "Authorization": "Token " + token,
                          },
                          body: json.encode({
                            "start_time": _timeStart.toString().substring(10, 15),
                            "end_time": _timeEnd.toString().substring(10, 15),
                            "duration": _duration.toString().substring(0, 7),
                            "start_date": _dateTimeStart.toString().substring(0, 10),
                            "end_date": _dateTimeEnd.toString().substring(0, 10),
                          }))
                      .timeout(const Duration(seconds: 10))
                      .then((response) {
                    print((response.body));
                    _start_times = json.decode(response.body)["start_time"];
                    _end_times = json.decode(response.body)["end_time"];
                    print(_start_times);
                    final body = json.encode({
                      "activity": {
                        "title": "AI Helper",
                        "start_times": [_start_times],
                        "end_times": [_end_times],
                        "recurring": false,
                        "repetition": null
                      },
                      "priority": 50,
                      "privacy": {"privacy": "personal"}
                    });
                    print(body);
                    print("0-----------------------------0");
                    const url1 = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/';

                    http
                        .post(url1,
                            headers: {
                              "Authorization": "Token " + token,
                              HttpHeaders.CONTENT_TYPE: "application/json",
                            },
                            body: body)
                        .then((response) {
                      if (response.statusCode == 201) {
                        snackBar = SnackBar(content: Text('Added Successfully'));
                        navigateToActivity(context);
                      } else {
                        print(response.statusCode);
                        snackBar = SnackBar(content: Text('Wrong creditentials, try again'));
                      }
                    });
                  });
                },
              )),
        ],
      ),
    );
  }
}

void navigateToActivity(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityListScreen()));
}
