import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optifyapp/ActivityListScreen.dart';
import 'AcivityAI.dart';
import 'models/api.dart';
import 'dart:async';
import 'providers/activities.dart';

class NewActivityPersonal extends StatefulWidget {
  var token, schedule_id;
  NewActivityPersonal({this.token, this.schedule_id});
  NewActivityPersonalPage createState() => NewActivityPersonalPage();
}

class NewActivityPersonalPage extends State<NewActivityPersonal> {
  String _ActivityName, _start_times, _end_times;
  double _discreteValue = 10.0;
  DateTime _dateTimeStart, _dateTimeEnd;
  var snackBar;
  String token ;
  TimeOfDay _timeStart, _timeEnd;
  String schedule_id;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    token = extractedUserData['token'];
    schedule_id = extractedUserData['schedule_id'].toString();
  }

  @override
  void initState() {
    if(widget.token == null){
      getToken();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: float2(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Activity Name'),
                    keyboardType: TextInputType.text,
                    onChanged: (String val) {
                      _ActivityName = val;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Start Date',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      OutlineButton(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        //
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: _start_times == null
                            ? Container(width: 200, child: Center(child: Text('Not Set')))
                            : Container(
                                width: 200,
                                child: Center(
                                  child: Text(DateFormat.MMMd()
                                          .format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_start_times).toString()))
                                          .toString() +
                                      " , " +
                                      DateFormat.Hm()
                                          .format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_start_times).toString()))
                                          .toString()),
                                ),
                              ),
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
                      SizedBox(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'End Date ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      OutlineButton(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: _end_times == null
                            ? Container(
                                width: 200,
                                child: Center(
                                  child: Text(
                                    'Not Set',
//                        style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            : Container(
                                width: 200,
                                child: Center(
                                  child: Text(
                                    DateFormat.MMMd().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_end_times).toString())).toString() +
                                        " , " +
                                        DateFormat.Hm()
                                            .format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_end_times).toString()))
                                            .toString(),
//                        style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
                      SizedBox(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              const Text(
//                'Duration',
//                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
//              ),
//              Container(
//                width: 130,
//                child: DropdownButton<String>(
//                  hint: Text("Not Set"),
//                  items: <String>['Monthly', 'Weekly', 'Daily'].map((String value) {
//                    return DropdownMenuItem<String>(
//                      value: value,
//                      child: Text(value),
//                    );
//                  }).toList(),
//                  onChanged: (_) {},
//                ),
//              ),
//              SizedBox(),
//            ],
//          ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Type    ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      Container(
                        width: 130,
                        child: DropdownButton<String>(
                          hint: Text('Not Set'),
                          items: <String>['Work', 'Recreational', 'Entertainment', 'Education', 'Social'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (_) {},
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(
                          width: 18,
                        ),
                        Text(
                          "Add Activity",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {
                      post();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future post() async {
    if(schedule_id == null || token == null ){
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];
      schedule_id = extractedUserData['schedule_id'].toString();
    }
    String url = Api.newActivityPersonal + schedule_id.toString() + "/activities/";
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
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
          
        print(response.statusCode);
      if (response.statusCode == 201) {
        Provider.of<Activities>(context, listen: false).fetchAndSetMyActivities(token, schedule_id);
        Navigator.pop(context);
        Flushbar(
          title: "Done",
          message: "Activity added",
          aroundPadding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      } else {
        snackBar = SnackBar(content: Text('Wrong creditentials, try again'));
      }
    });
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
}
