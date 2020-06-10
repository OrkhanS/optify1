import 'dart:convert';
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/providers/activities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AcivityAI.dart';
import '../NewActivityJoint.dart' as joint;
import '../models/api.dart';
import '../newActivityPersonal.dart' as personal;
import 'package:http/http.dart' as http;

class AddActivityScreen extends StatefulWidget {
  var token, schedule_id;
  AddActivityScreen({this.token, this.schedule_id});
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> with SingleTickerProviderStateMixin {
  String _ActivityName;
  double _discreteValue = 10.0;
  DateTime _dateTime;
  TimeOfDay _time; //After we get time, add it into FROM and UNTIL section below, no need to ask it again below
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool modePersonal = true;
  TabController controller;
  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.chevron_left,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Add Activity',
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
          ),
//        bottom: TabBar(
//
//          indicatorColor: Colors.lime,
//          controller: controller,
//          tabs: <Widget>[
//            InkWell(
//              onTap: () {
//                if (!modePersonal)
//                  setState(() {
//                    modePersonal = false;
//                  });
//              },
//              child: Tab(
//                child: Text(
//                  "Personal",
//                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
//                ),
//              ),
//            ),
//            InkWell(
//              onTap: () {
//                if (modePersonal)
//                  setState(() {
//                    modePersonal = true;
//                  });
//              },
//              child: Tab(
//                child: Text(
//                  "Joint",
//                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
//                ),
//              ),
//            )
//          ],
//        ),
        ),
        body: AddActivity(token: widget.token, schedule_id: widget.schedule_id)
//        Container(
//          height: 200,
//          width: 200,
//          color: Colors.green,
//        )
//      TabBarView(
//        controller: controller,
//        children: <Widget>[personal.NewActivityPersonal(token: widget.token, schedule_id: widget.schedule_id), joint.NewActivityJoint()],
//      ),
        );
  }
}

class AddActivity extends StatefulWidget {
  var token, schedule_id;
  AddActivity({this.token, this.schedule_id});
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  String _ActivityName, _start_times, _end_times;
  double _discreteValue = 10.0;
  DateTime _dateTimeStart, _dateTimeEnd;
  var snackBar;
  String token;
  TimeOfDay _timeStart, _timeEnd;
  String schedule_id;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _modePersonal = true;
  bool _modeAI = false;

  Duration _duration;

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
    getToken();
    super.initState();
  }

  void _switchModePersonal() {
    if (_modePersonal) {
      setState(() {
        _modePersonal = false;
      });
    } else {
      setState(() {
        _modePersonal = true;
      });
    }
  }

  void _switchModeAI() {
    if (_modeAI) {
      setState(() {
        _modeAI = false;
      });
    } else {
      setState(() {
        _modeAI = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      height: deviceSize.height * 0.9,
      width: deviceSize.width,
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            color: _modeAI ? Theme.of(context).primaryColor : Colors.white,
                            onPressed: () {
                              _switchModeAI();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _modeAI
                                    ? Icon(
                                        MdiIcons.brain,
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        Icons.schedule,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                _modeAI
                                    ? Text("  AI Generated", style: TextStyle(color: Colors.white))
                                    : Text(
                                        "  Fixed",
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                      ),
                              ],
                            )),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: RaisedButton(
                            color: _modePersonal ? Colors.white : Theme.of(context).primaryColor,
                            onPressed: () {
                              _switchModePersonal();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _modePersonal
                                    ? Icon(
                                        Icons.person,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Icon(
                                        MdiIcons.accountGroup,
                                        color: Colors.white,
                                      ),
                                _modePersonal
                                    ? Text("    Personal", style: TextStyle(color: Theme.of(context).primaryColor))
                                    : Text(
                                        "    Joint",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                              ],
                            )),
                      )
                    ],
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Activity Name'),
                  keyboardType: TextInputType.text,
                  onChanged: (String val) {
                    _ActivityName = val;
                  },
                ),
                Divider(),
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
                                    DateFormat.Hm().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_start_times).toString())).toString()),
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
                Divider(),
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
                                      DateFormat.Hm().format(DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").parse(_end_times).toString())).toString(),
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
                Divider(),
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
                if (_modeAI)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Duration',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                          width: 250,
                          height: 120,
                          child: CupertinoTimerPicker(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              mode: CupertinoTimerPickerMode.hm,
                              initialTimerDuration: Duration.zero,
                              minuteInterval: 5,
                              onTimerDurationChanged: (time) {
                                setState(() {
                                  _duration = time;
                                });
                              })),
                    ],
                  ),
//                Divider(),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    const Text(
//                      'Duration',
//                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
//                    ),
//                    Container(
//                      width: 130,
//                      child: DropdownButton<String>(
//                        value: duration,
//                        hint: Text("Not Set"),
//                        items: <String>['Monthly', 'Weekly', 'Daily'].map((String value) {
//                          return DropdownMenuItem<String>(
//                            value: value,
//                            child: Text(value),
//                          );
//                        }).toList(),
//                        onChanged: (val) {
//                          setState(() {
//                            duration = val;
//                          });
//                        },
//                      ),
//                    ),
//                    SizedBox(),
//                  ],
//                ),
//                Divider(),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    const Text(
//                      'Type    ',
//                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
//                    ),
//                    Container(
//                      width: 130,
//                      child: DropdownButton<String>(
//                        hint: Text('Not Set'),
//                        items: <String>['Work', 'Recreational', 'Entertainment', 'Education', 'Social'].map((String value) {
//                          return DropdownMenuItem<String>(
//                            value: value,
//                            child: Text(value),
//                          );
//                        }).toList(),
//                        onChanged: (_) {},
//                      ),
//                    ),
//                    SizedBox(),
//                  ],
//                ),
                Divider(),
                if (!_modePersonal)
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: const Text(
                          'Members',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: <Widget>[
                            //todo display members
                            OutlineButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.edit, size: 15, color: Theme.of(context).primaryColor),
                                  Text(
                                    " Manage participants",
                                    style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 100,
                              child: GridView.count(
                                childAspectRatio: 3,
                                crossAxisCount: 2,
                                children: <Widget>[
                                  for (var i = 0; i < 11; i++) //todo Orxan list members
                                    Chip(
                                      backgroundColor: Colors.green[100],
                                      deleteIcon: Icon(Icons.cancel),
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade800,
                                        child: Text('KS'),
                                      ),
                                      label: Text('Kazato Suriname'), //todo fix Name
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (!_modePersonal)
                  Divider(),
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
    );
  }

  Future post() async {
    if (schedule_id == null || token == null) {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];
      schedule_id = extractedUserData['schedule_id'].toString();
    }
    String url = Api.newActivityPersonal + widget.schedule_id.toString() + "/activities/";
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
        print(response.body);
        snackBar = SnackBar(content: Text('Wrong details, try again'));
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

  void navigateToActivityAI(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityAI()));
  }
}
