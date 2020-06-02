import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/ActivityListScreen.dart';
import 'AcivityAI.dart';
import 'ActivityClass.dart';
import 'models/api.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/activities.dart';

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
  TimeOfDay _timeStart, _timeEnd;
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
          Provider.of<Activities>(context, listen: false).addActivityFromPostRequest(json.decode(response.body));
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
  }

  Widget FormUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Activity Name'),
            keyboardType: TextInputType.text,
            onChanged: (String val) {
              _ActivityName = val;
            },
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
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    //
                    child: _start_times == null
                        ? Text('Start Date')
                        : Text(DateFormat.MMMd().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_start_times).toString())).toString() +
                            "\n" +
                            DateFormat.Hm().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_start_times).toString())).toString()),
                    color: Colors.white,
                    onPressed: () {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((time) {
                        _timeStart = time;
                        _start_times = _dateTimeStart.toString().substring(0, 11) + _timeStart.toString().substring(10, 15);
                        setState(() {});
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
                      padding: EdgeInsets.all(8.0),
                      child: _end_times == null
                          ? Text(
                              'End Date',
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              DateFormat.MMMd().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_end_times).toString())).toString() +
                                  "\n" +
                                  DateFormat.Hm().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_end_times).toString())).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((time) {
                          _timeEnd = time;
                          _end_times = _dateTimeEnd.toString().substring(0, 11) + _timeEnd.toString().substring(10, 15);
                          setState(() {});
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Priority',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
              Expanded(
                child: Slider(
                  value: _discreteValue,
                  activeColor: Theme.of(context).primaryColor,
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
            ],
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: DropdownButton<String>(
                    hint: new Text("Duration"),
                    items: <String>['Monthly', 'Weekly', 'Daily'].map((String value) {
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
                    items: <String>['Work', 'Recreational', 'Entertainment', 'Education', 'Social'].map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.save, color: Colors.white),
                      Text(
                        "  Save",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  onPressed: () {
                    function1().whenComplete(post);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget float2(context) {
  return Container(
    child: FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      heroTag: "btn2",
      onPressed: () {
        navigateToActivityAI(context);
      },
      tooltip: 'Second button',
      child: Icon(MdiIcons.brain, color: Colors.white),
    ),
  );
}

void navigateToActivity(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityListScreen()));
}

void navigateToActivityAI(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityAI()));
}
