import 'dart:convert';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/providers/activities.dart';
import 'package:optifyapp/providers/contactsgroups.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import '../models/api.dart';
import 'package:http/http.dart' as http;

import 'managepar_screen.dart';

class AddActivityScreen extends StatefulWidget {
  final token;
  AddActivityScreen({@required this.token});
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  String _ActivityName;
  DateTime _start, _end;
  double _discreteValue = 10.0;
  DateTime _dateTimeStart, _dateTimeEnd;
  var snackBar;
  String token;
  DateTime _timeStart, _timeEnd;
  String schedule_id;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _modeAI = false;
  var categoryValue = 'Routine';
  var defPrivacy = 'Friends';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton(
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
          if(_modeAI == true){
             initCommunication();
            //postAI();
          }else{
           post();
          }
          
        },
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          height: deviceSize.height * 0.9,
          width: deviceSize.width,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Icon(
                          Icons.chevron_left,
                          size: 27,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.schedule,
                            color: !_modeAI ? Theme.of(context).primaryColor : Colors.black45,
                          ),
                          Text(
                            "  Fixed     ",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: !_modeAI ? Theme.of(context).primaryColor : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            MdiIcons.brain,
                            color: _modeAI ? Theme.of(context).primaryColor : Colors.black45,
                          ),
                          Text(" AI Generated",
                              style: TextStyle(
                                fontSize: 18,
                                color: _modeAI ? Theme.of(context).primaryColor : Colors.black45,
                              )),
                        ],
                      ),
                      Switch(
                        value: _modeAI,
                        onChanged: (value) {
                          setState(() {
                            _switchModeAI();
                          });
                        },
                        activeTrackColor: Theme.of(context).primaryColorLight,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Activity Title'),
                          keyboardType: TextInputType.text,
                          onChanged: (String val) {
                            _ActivityName = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
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
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: OutlineButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          //
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: _dateTimeStart == null
                              ? Container(
                                  child: Center(child: Text('Start Date')),
                                )
                              : Container(
                                  child: Center(
                                    child: Text(
//                                    _dateTimeStart.toString(),
                                      DateFormat.MMMMd().format(_dateTimeStart).toString() + ", " + _dateTimeStart.year.toString(),
                                    ),
                                  ),
                                ),
                          color: Colors.white,
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              locale: const Locale('en', 'GB'),
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2019),
                              lastDate: DateTime(2222),
                            ).then(
                              (date) {
                                setState(() {
                                  _dateTimeStart = date;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: OutlineButton(
//                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          //
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: _timeStart == null
                              ? Container(
                                  child: Center(child: Text('Start Time')),
                                )
                              : Container(
                                  child: Center(
                                    child: Text(
                                      DateFormat.Hm().format(_timeStart),
                                    ),
                                  ),
                                ),
                          color: Colors.white,
                          onPressed: () {
                            DatePicker.showTimePicker(context,
                                showSecondsColumn: false,
                                theme: DatePickerTheme(
                                  doneStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  itemStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  containerHeight: 210.0,
                                ),
                                showTitleActions: true, onConfirm: (time) {
                              setState(() {
                                _timeStart = time;
                              });
                            }, currentTime: DateTime.now(), locale: LocaleType.en);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: OutlineButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: _dateTimeEnd == null
                              ? Container(
                                  child: Center(child: Text('End Date')),
                                )
                              : Container(
                                  child: Center(
                                    child: Text(
                                      DateFormat.MMMd().format(_dateTimeEnd).toString() + ", " + _dateTimeEnd.year.toString(),
                                    ),
                                  ),
                                ),
                          color: Colors.white,
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              locale: const Locale('en', 'GB'),
                              initialDate: _dateTimeStart == null ? DateTime.now() : _dateTimeStart,
                              firstDate: DateTime(2019),
                              lastDate: DateTime(2222),
                            ).then(
                              (date) {
                                setState(() {
                                  _dateTimeEnd = date;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: OutlineButton(
//                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          //
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: _timeEnd == null
                              ? Container(
                                  child: Center(child: Text('End Time')),
                                )
                              : Container(
                                  child: Center(
                                    child: Text(
                                      DateFormat.Hm().format(_timeEnd),
                                    ),
                                  ),
                                ),
                          color: Colors.white,
                          onPressed: () {
                            DatePicker.showTimePicker(
                              context,
                              showSecondsColumn: false,
                              currentTime: _timeStart == null ? DateTime.now() : _timeStart,
                              locale: LocaleType.en,
                              theme: DatePickerTheme(
                                doneStyle: TextStyle(color: Theme.of(context).primaryColor),
                                itemStyle: TextStyle(color: Theme.of(context).primaryColor),
                                containerHeight: 210.0,
                              ),
                              showTitleActions: true,
                              onConfirm: (time) {
                                setState(() {
                                  _timeEnd = time;
                                });
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Divider(),
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
                            height: 80,
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
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Category',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(width: 100),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: 130,
                          child: DropdownButton<String>(
                            value: categoryValue,
                            items: <String>['Routine', 'Academic', 'Social', 'Professional', 'Recreational', 'Sport'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                categoryValue = val;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Privacy',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(width: 100),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: 130,
                          child: DropdownButton<String>(
                            value: defPrivacy,
                            items: <String>['Private', 'Friends', 'Public'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                defPrivacy = val;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Members',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                      Expanded(child: SizedBox()),
                      OutlineButton(
                        onPressed: () {
                                        Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageParticipants(token:widget.token)));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.edit, size: 15, color: Theme.of(context).primaryColor),
                            Text(
                              "  Manage Participants",
                              style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          ///Membercount / 2 * 40
                          height: 2 * 43.0,
                          child: MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: GridView.count(
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 5,
                                crossAxisCount: 2,
                                children: <Widget>[
                                  for (var i = 0; i < Provider.of<ContactsGroups>(context,listen: true).activityMembers.length; i++) 
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColorLight,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: Colors.grey.shade100,
                                            child: Text(
                                              Provider.of<ContactsGroups>(context).activityMembers[i]["name"].toString().substring(0,1)+
                                              Provider.of<ContactsGroups>(context).activityMembers[i]["name"].toString().split(" ")[1].substring(0,1)
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(Provider.of<ContactsGroups>(context).activityMembers[i]["name"].toString()),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    if (schedule_id == null || token == null) {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];
      schedule_id = extractedUserData['schedule_id'].toString();
    }
    _start = new DateTime(_dateTimeStart.year, _dateTimeStart.month, _dateTimeStart.day, _timeStart.hour, _timeStart.minute);

    _end = new DateTime(_dateTimeEnd.year, _dateTimeEnd.month, _dateTimeEnd.day, _timeEnd.hour, _timeEnd.minute);

    String url = Api.newActivityPersonal + schedule_id.toString() + "/activities/";
    var members = Provider.of<ContactsGroups>(context).activityMembers;
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({
              "activity": {
                "title": _ActivityName,
                "start_times": [_start.toString()],
                "end_times": [_end.toString()],
                "weekdays": ["Monday"],
              },
              "category": categoryValue,
              "priority": _discreteValue.toInt(),
              "privacy": {"privacy": defPrivacy.toLowerCase(),},
              "members": members,

            }))
        .then((response) {
        Provider.of<ContactsGroups>(context).activityMembers = [];  
      if (response.statusCode == 201) {
        
        Provider.of<Activities>(context).addActivityFromPostRequest(json.decode(response.body));
        Navigator.pop(context);
        Flushbar(
          title: "Done",
          message: "Activity added",
          padding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      } else {
        Flushbar(
          title: "Error",
          message: "'Wrong details, try again'",
          padding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    });
  }
  
  ObserverList<Function> _listeners = new ObserverList<Function>();
  bool enableButton = false;
  bool _isOn = false;
  IOWebSocketChannel _channelRoom;
  IOWebSocketChannel alertChannel;

  initCommunication() async {
    reset();
    try {
      _channelRoom =
          new IOWebSocketChannel.connect(Api.aiSocket + '?token=' + token.toString());
      _channelRoom.stream.listen(_onReceptionOfMessageFromServer);
      print("Room Socket Connected");
      handleSendMessage();
    } catch (e) {}
  }

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
  }

  _onReceptionOfMessageFromServer(message) {
    print(message);
    _isOn = true;
    _listeners.forEach((Function callback) {
      callback(message);
    });
  }

  reset() {
    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        _channelRoom.sink.close();
        _isOn = false;
      }
    }
  }

  void handleSendMessage() {
    var message ={};
    _start = new DateTime(_dateTimeStart.year, _dateTimeStart.month, _dateTimeStart.day);
    _end = new DateTime(_dateTimeEnd.year, _dateTimeEnd.month, _dateTimeEnd.day);

    message["command"] = "best_timeslot";
    message["start_date"] = _start.toString();
    message["end_date"] = _end.toString();
    message["title"] = _ActivityName.toString();
    message["duration"] = (_duration.inMinutes~/60).toString();
    message["members"] = Provider.of<ContactsGroups>(context).activityMembers;

    if (_channelRoom != null) {
      if (_channelRoom.sink != null) {
        _channelRoom.sink.add(jsonEncode(message).toString());
      }
    }
  }



  Future postAI() async {
    if (schedule_id == null || token == null) {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
      token = extractedUserData['token'];
      schedule_id = extractedUserData['schedule_id'].toString();
    }
    _start = new DateTime(_dateTimeStart.year, _dateTimeStart.month, _dateTimeStart.day, _timeStart.hour, _timeStart.minute);

    _end = new DateTime(_dateTimeEnd.year, _dateTimeEnd.month, _dateTimeEnd.day, _timeEnd.hour, _timeEnd.minute);

    String url = Api.newActivityPersonal + schedule_id.toString() + "/activities/";
    var members = Provider.of<ContactsGroups>(context).activityMembers;
    http
        .post(url,
            headers: {
              "Authorization": "Token " + token,
              HttpHeaders.CONTENT_TYPE: "application/json",
            },
            body: json.encode({
              "activity": {
                "title": _ActivityName,
                "start_times": [_start.toString()],
                "end_times": [_end.toString()],
                "weekdays": ["Monday"],
              },
              "category": categoryValue,
              "priority": _discreteValue.toInt(),
              "privacy": {"privacy": defPrivacy.toLowerCase(),},
              "members": members,

            }))
        .then((response) {
        Provider.of<ContactsGroups>(context).activityMembers = [];  
      if (response.statusCode == 201) {
        
        Provider.of<Activities>(context).addActivityFromPostRequest(json.decode(response.body));
        Navigator.pop(context);
        Flushbar(
          title: "Done",
          message: "Activity added",
          padding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      } else {
        Flushbar(
          title: "Error",
          message: "'Wrong details, try again'",
          padding: const EdgeInsets.all(30),
          borderRadius: 10,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    });
    
  }

}
