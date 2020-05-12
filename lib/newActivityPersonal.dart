import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/ActivityListScreen.dart';
import 'AcivityAI.dart';
import 'models/api.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(
      home: newActivityPersonal(),
    ));

class newActivityPersonal extends StatefulWidget {
  var token, schedule_id;
  newActivityPersonal({this.token, this.schedule_id});
  newActivityPersonalPage createState() => newActivityPersonalPage();
}

class newActivityPersonalPage extends State<newActivityPersonal> {
  String _ActivityName, _start_times, _end_times;
  double _discreteValue = 10.0;
  DateTime _dateTimeStart, _dateTimeEnd;
  var snackBar;
  String tokenforROOM;
  TimeOfDay _timeStart, _timeEnd; //After we get time, add it into FROM and UNTIL section below, no need to ask it again below
  String schedule_id;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: float2(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    );
  }

  post() {
    String url = Api.newActivityPersonal + schedule_id.toString() + "/activities/";
    http
        .post(url,
            headers: {
              "Authorization": "Token " + tokenforROOM,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({
              "activity": {
                "title": _ActivityName,
                "start_times": [_start_times],
                "end_times": [_end_times],
                "weekdays": ["Monday"],
              },
              "priority": _discreteValue.toInt(),
              "privacy": {"privacy": "personal"}
            }))
        .then((response) {
      if (response.statusCode == 201) {
        Navigator.pop(context);
        Flushbar(
          title: "Done",
          message: "Activity added",
          aroundPadding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      } else {
        print(response.statusCode);
        snackBar = SnackBar(content: Text('Wrong creditentials, try again'));
      }
    });
  }

  Future function1() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    tokenforROOM = extractedUserData['token'];
    final prefs2 = await SharedPreferences.getInstance();
    if (!prefs2.containsKey('scheduleData')) {
      return false;
    }
    final extractedscheduleData = json.decode(prefs2.getString('scheduleData')) as Map<String, Object>;
    schedule_id = extractedscheduleData['schedule_id'];
    print("I am here");
    print(tokenforROOM);
    print(schedule_id);
  }

  Widget FormUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 275.0,
            child: new TextFormField(
              decoration: const InputDecoration(labelText: 'Activity Name'),
              keyboardType: TextInputType.text,
              onChanged: (String val) {
                _ActivityName = val;
              },
            ),
          ),
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
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((time) {
                        _timeStart = time;
                        _start_times = _dateTimeStart.toString().substring(0, 11) + _timeStart.toString().substring(10, 15);
                      });
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2222),
                      ).then(
                        (date) {
                          _dateTimeStart = date;
                        },
                      );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15.0),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      height: 60,
                      minWidth: 130,
                      padding: EdgeInsets.all(8.0),
                      child: Text('End Date'),
                      color: Colors.white,
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((time) {
                          _timeEnd = time;
                          _end_times = _dateTimeEnd.toString().substring(0, 11) + _timeEnd.toString().substring(10, 15);
                        });
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2222),
                        ).then((date) {
                          _dateTimeEnd = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(margin: EdgeInsets.only(top: 30.0), child: const Text('Priority')),
          Container(
            width: 330.0,
            child: Slider(
              value: _discreteValue,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: '${_discreteValue.round()}',
              onChanged: (double value) {
                setState(() {
                  _discreteValue = value;
                });
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: DropdownButton<String>(
                    hint: new Text("Duration"),
                    items: <String>['Montly', 'Weekly', 'Daily'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: new DropdownButton<String>(
                    hint: Text('Type'),
                    items: <String>['Work', 'Recriational', 'Entertainment', 'Education', 'Social'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),
          Container(
              width: 50.0,
              height: 50.0,
              child: FloatingActionButton(
                tooltip: 'Save',
                child: Icon(Icons.save),
                onPressed: () {
                  function1().whenComplete(post);
                },
              )),
        ],
      ),
    );
  }
}

Widget float2(context) {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn2",
      onPressed: () {
        navigateToActivityAI(context);
      },
      tooltip: 'Second button',
      child: Icon(Icons.search),
    ),
  );
}

void navigateToActivity(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityListScreen()));
}

void navigateToActivityAI(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityAI()));
}
