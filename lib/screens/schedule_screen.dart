import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/screens/addActivity_screen.dart';
import 'package:optifyapp/models/api.dart';
import 'package:optifyapp/providers/activities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/activityBox.dart';
import 'package:optifyapp/ActivityClass.dart';
import 'package:optifyapp/screens/addActivity_screen.dart' as activityPageNew;
import '../providers/activities.dart';

void main() => runApp(ScheduleScreen());

class ScheduleScreen extends StatefulWidget {
  var token, auth, schedule_id;
  Activities activitiesProvider;
  ScheduleScreen({this.auth, this.token, this.schedule_id, this.activitiesProvider});
  @override
  ScheduleScreenMain createState() => ScheduleScreenMain();
}

class ScheduleScreenMain extends State<ScheduleScreen> {
  List _activity = [];
  String nextOrderURL;
  bool isSwitched = true;
  String token;
  String schedule_id;

  Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    token = extractedUserData['token'];
    schedule_id = extractedUserData['schedule_id'].toString();
    loadMyActivites();
  }

  loadMyActivites() async {
    if (widget.activitiesProvider != null) {
      if (widget.activitiesProvider.isLoadingActivities == true && token != null && token != "null") {
        widget.activitiesProvider.fetchAndSetMyActivities(token, schedule_id);
      }
    }
  }

  @override
  void initState() {
    // getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var nowWeekday = now.weekday;

    return Consumer<Activities>(
      builder: (context, activitiesProvider, child) {
        if (activitiesProvider.activities.length != 0) {
          _activity = activitiesProvider.activities;
          if (nextOrderURL == "FirstCall") {
            nextOrderURL = activitiesProvider.detailsActivities["next"];
          }
        } else {
          //messageLoader = true;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
//                IconButton(
//                  icon: Icon(Icons.format_list_bulleted),
//                  color: Theme.of(context).primaryColor,
//                  onPressed: () {},
//                ),

//                FlatButton(
//                  child: Container(
//                      padding: EdgeInsets.all(10),
//                      decoration: BoxDecoration(
//                        border: Border.all(color: Theme.of(context).primaryColor, width: 1),
//                        borderRadius: BorderRadius.circular(5),
//                      ),
//                      child: Text(
//                        "List Activities",
//                        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 13),
//                      )),
////                  color: Colors.red[100],
//                  onPressed: () {},
//                ),

                Text(
                  "Schedule",
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
//                SizedBox(
//                  width: 100,
//                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    "Default",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
//              FlatButton(
//                child: Container(
//                    padding: EdgeInsets.all(10),
//                    decoration: BoxDecoration(
//                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
//                      borderRadius: BorderRadius.circular(5),
//                    ),
//                    child: Text(
//                      "Heatmap",
//                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 13),
//                    )),
////                  color: Colors.red[100],
//                onPressed: () {},
//              ),
              Transform.rotate(
                angle: 3.14 / 2,
                child: Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeTrackColor: Theme.of(context).primaryColorLight,
                  activeColor: Theme.of(context).primaryColor,
                ),
              )
            ],
            centerTitle: true,
            elevation: 1,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivityScreen(token: token, schedule_id: schedule_id)));
            },
            tooltip: 'First button',
            child: Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Provider.of<Activities>(context, listen: true).isLoadingActivities == true
              ? Center(child: CircularProgressIndicator())
              : isSwitched
                  ? ListView.builder(
                      //todo Refresh activities
                      itemCount: 5,

//                      itemExtent: 100,

                      physics: const PageScrollPhysics(),
//                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
//                        return Container(
//                          margin: EdgeInsets.all(5),
//                          width: 150,
//                          height: 50,
//                          color: Colors.black,
//                        );
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 7),
                            elevation: 1,
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
                        );
                      },
                    )
                  : _activity.isEmpty
                      ? Center(child: Text("No Activity"))
                      : Container(
                          child: ListView.builder(
                            itemBuilder: (context, int i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Dismissible(
                                  direction: DismissDirection.endToStart,
                                  movementDuration: Duration(milliseconds: 500),
                                  dragStartBehavior: DragStartBehavior.start,
                                  onDismissed: (direction) {
                                    String url = Api.myActivities + "1" + "/activities/" + _activity[i]["activity"]["id"].toString() + "/";
                                    http.delete(
                                      url,
                                      headers: {
                                        HttpHeaders.CONTENT_TYPE: "application/json",
                                        "Authorization": "Token " + token,
                                      },
                                    );
                                    _activity.removeAt(i);

                                    Flushbar(
                                      title: "Done!",
                                      message: "Activity was deleted",
                                      aroundPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                                      borderRadius: 10,
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                  },
                                  confirmDismiss: (DismissDirection direction) async {
                                    final bool res = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text("Are you sure you wish to delete this item?"),
                                          actions: <Widget>[
                                            FlatButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                                            FlatButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return res; //todo check
                                  },
                                  background: Container(
                                    margin: EdgeInsets.all(3),
                                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red[700], Colors.orange[300]])),
//                                    border: Border.all(),
//                                    borderRadius: BorderRadius.circular(5),
//                                  ),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(width: 40),
                                        Icon(
                                          MdiIcons.delete,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "DELETE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                  ),
                                  key: ValueKey(i),
                                  child: InkWell(
                                    onTap: () => null,
                                    child: Container(
//                              height: 140,
                                      child: Card(
                                        elevation: 1,
                                        child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Transform.rotate(
                                                    angle: 3.18,
                                                    child: CircularProgressIndicator(
//                                          value: Tween<Double>(0.0, int.parse(_activity[i]["priority"].toString()).toDouble() / 100).animate(parent),
                                                      value: int.parse(_activity[i]["priority"].toString()).toDouble() / 100,
                                                      strokeWidth: 4,
                                                      valueColor: new AlwaysStoppedAnimation<Color>(
                                                        Colors.lightGreen[_activity[i]["priority"] * 9 - (_activity[i]["priority"] * 9) % 100 + 100],
                                                      ),
                                                      backgroundColor: Colors.grey[100],
                                                    ),
                                                  ),
                                                  Text(
                                                    _activity[i]["priority"].toString(),
                                                    style: TextStyle(color: Colors.grey[900], fontSize: 15, fontWeight: FontWeight.w400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    /* todo RASUL
_activity[0]["priority"]
_activity[0]["activity"]["title"]
_activity[0]["activity"]["start_times"][0]
_activity[0]["activity"]["end_times"][0]
_activity[0]["activity"]["weekdays"][0]
_activity[0]["activity"]["durations"][0]
*/
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          _activity[i]["activity"]["title"],
                                                          style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                                        ),
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(DateTime.parse(_activity[i]["activity"]["start_times"][0]))
                                                              .toString(),
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.timer,
                                                          color: Theme.of(context).primaryColor,
                                                        ),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: DateFormat.Hm()
                                                                    .format(DateTime.parse(_activity[i]["activity"]["start_times"][0]))
                                                                    .toString() +
                                                                " - " +
                                                                DateFormat.Hm()
                                                                    .format(DateTime.parse(_activity[i]["activity"]["end_times"][0]))
                                                                    .toString(),
                                                            style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
//                                          Row(
//                                            children: <Widget>[
//                                              Icon(
//                                                Icons.date_range,
//                                                color: Theme.of(context).primaryColor,
//                                              ),
//                                              Text(
//                                                DateFormat.yMMMd().format(DateTime.parse(_activity[i]["activity"]["start_times"][0])).toString(),
//                                                style: TextStyle(color: Colors.grey[600]),
//                                              ),
//                                            ],
//                                          ),
//                                          Row(
//                                            children: <Widget>[
//                                              Icon(
//                                                MdiIcons.weightKilogram, //todo: icon
////                                            (FontAwesome.suitcase),
//                                                color: Theme.of(context).primaryColor,
//                                              ),
//                                              Text(
//                                                _activity[i]["priority"].toString(),
//                                                style: TextStyle(color: Colors.grey[600]),
//                                              ),
//                                            ],
//                                          )
                                                  ],
                                                ),
                                              ),
                                            ),

//                                    Image(
//                                      image: NetworkImage("https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
//                                      height: 60,
//                                      width: 60,
//                                    ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: _activity == null ? 0 : _activity.length,
                          ),
                        ),
        );
      },
    );
  }
}

class FullTime extends StatefulWidget {
  final List activityList;
  FullTime({Key key, @required this.activityList}) : super(key: key);

  @override
  FullTimeState createState() => FullTimeState();
}

class FullTimeState extends State<FullTime> {
  double scaleHeight = 40;
  double check = 40;

  final _scrollController = ScrollController(initialScrollOffset: 300);
  @override
  Widget build(BuildContext context) {
//    _animateToIndex(8.0);
    return Flexible(
      child: GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          check = ((scaleHeight * scaleDetails.scale / 100).round()).toDouble();
          if (check > 30 && check < 150) {
            setState(() {
              scaleHeight = check;
            });
          } else {
            check = scaleHeight;
          }
        },
        child: Container(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Stack(
                children: [
                  Column(
                    children: <Widget>[
                      for (var i = 0; i < 24; i++)
                        if (i > 9)
                          hourRow(time: "${i.toString()}:00", vertical: scaleHeight)
                        else
                          hourRow(time: "0${i.toString()}:00", vertical: scaleHeight),
                    ],
                  ),

                  if (widget.activityList != null)
                    for (var x = widget.activityList.length - 1; x >= 0; x--)
                      ActivityBox(
                        context: context,
                        myActivity: widget.activityList[x],
                        height: scaleHeight / 60,
                      ),
//                  if (widget.activityList != null)
//                    for (var x in widget.activityList)
//                      ActivityBox(
//                        context: context,
//                        myActivity: x,
//                        height: scaleHeight / 60,
//                      ),
//                activityBoxObject(context, x, scaleHeight / 60),
//                activityBox(
//                    height: scaleHeight / 60,
//                    duration: 120,
//                    days: 5,
//                    starttime: 19,
//                    startday: 1, //1 - monday, 5 friday
//                    name: "Work",
//                    description: "Workout at gym"),
                ],
              ),
            ),
          ),
//            ],
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

Widget float1(context, token, schedule_id) {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn1",
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivityScreen(token: token, schedule_id: schedule_id)));
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
