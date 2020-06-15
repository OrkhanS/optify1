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
import '../providers/activities.dart';

class ScheduleScreen extends StatefulWidget {
  var token, auth, schedule_id;
  Activities activitiesProvider;
  ScheduleScreen({this.auth, this.token, this.schedule_id, this.activitiesProvider});
  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  List _activity = [];
  String nextActivitiesURL = "FirstCall";
  String previousActivitiesURL = "FirstCall";
  bool isSwitched;
  String token;
  String schedule_id;
  var dateForMonth, dateForDay;
  bool _modePriority;
  var middle = 20;

  bool initialBuild;

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
    isSwitched = false;
    initialBuild = true;
    _modePriority = false;
  }
  
  func(){
    setState(() {
      _activity = Provider.of<Activities>(context, listen: true).getActivities[middle];
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var middle = 20;
    var nowWeekday = now.weekday;

    var date = DateTime.now();
    dateForMonth = DateFormat.MMMM().format(date);

    final _horizontalscrollController = ScrollController(initialScrollOffset: MediaQuery.of(context).size.width * (middle));

    return Consumer<Activities>(
      builder: (context, activitiesProvider, child) {
        if (activitiesProvider.notLoadingActivities == false) {
          _activity = Provider.of<Activities>(context, listen: true).getActivities[middle];
        } else {
          //messageLoader = true;
        }
        return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
//                  dateForMonth,
                    "Schedule",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    color: _modePriority ? Theme.of(context).primaryColor : Colors.white,
                    shape: new RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      _modePriority ? "Priority" : "Default",
                      style: TextStyle(color: _modePriority ? Colors.white : Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      setState(() {
                        _modePriority = !_modePriority;
                      });
                    },
                  ),
                ),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddActivityScreen(token: token)));
              },
              tooltip: 'First button',
              child: Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: Column(
              children: <Widget>[
                activitiesProvider.getActivities[20].isEmpty
                    ? Center(child: Text("No Activity"))
                    : AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: isSwitched ? MediaQuery.of(context).size.height * 0.8 : 0,
                        child: ListView.builder(
                          itemBuilder: (context, int i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Dismissible(
                                direction: DismissDirection.endToStart,
                                movementDuration: Duration(milliseconds: 500),
                                dragStartBehavior: DragStartBehavior.start,
                                onDismissed: (direction) {
                                  if(token == null){
                                    getToken().whenComplete(() => {
                                      activitiesProvider.removeActivity(schedule_id, _activity[i]["activity"]["id"], i, token)
                                    });
                                    
                                  } else{
                                    activitiesProvider.removeActivity(schedule_id, _activity[i]["activity"]["id"], i, token);
                                  }
                                  
                                  Flushbar(
                                    title: "Done!",
                                    message: "Activity was deleted",
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
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
                                                    value: int.parse(activitiesProvider.getActivities[20][i]["priority"].toString()).toDouble() / 100,
                                                    strokeWidth: 4,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(
                                                      Colors.lightGreen[activitiesProvider.getActivities[20][i]["priority"] * 9 -
                                                          (activitiesProvider.getActivities[20][i]["priority"] * 9) % 100 +
                                                          100],
                                                    ),
                                                    backgroundColor: Colors.grey[100],
                                                  ),
                                                ),
                                                Text(
                                                  activitiesProvider.getActivities[20][i]["priority"].toString(),
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
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        activitiesProvider.getActivities[20][i]["activity"]["title"],
                                                        style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                                      ),
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                DateTime.parse(activitiesProvider.getActivities[20][i]["activity"]["start_times"][0]))
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
                                                        size: 15,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                      RichText(
                                                        text: TextSpan(
                                                          text: "  " +
                                                              DateFormat.Hm()
                                                                  .format(DateTime.parse(
                                                                      activitiesProvider.getActivities[20][i]["activity"]["start_times"][0]))
                                                                  .toString() +
                                                              " - " +
                                                              DateFormat.Hm()
                                                                  .format(DateTime.parse(
                                                                      activitiesProvider.getActivities[20][i]["activity"]["end_times"][0]))
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
                          itemCount: activitiesProvider.getActivities == null ? 0 : activitiesProvider.getActivities[20].length,
                        ),
                      ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: isSwitched ? 0 : MediaQuery.of(context).size.height * .8,
                  child: Stack(
                    children: <Widget>[
                      ListView.builder(
                        //todo Refresh activities
                        controller: _horizontalscrollController,
                        itemCount: middle * 2,
//                      itemExtent: 100,
                        physics: const PageScrollPhysics(),
//                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (index < 15 && initialBuild) {
                            return Container(width: MediaQuery.of(context).size.width, child: Text('inititial Build'));
                          }
                          initialBuild = false;
                          date = DateTime.now().subtract(Duration(days: -7 * (index - middle)));

                          dateForMonth = DateFormat.MMMM().format(date);
                          // dateForDay = DateFormat.wee;
                          // final firstMonday = DateTime.now().weekday;
                          // final daysInFirstWeek = 8 - firstMonday;
                          // final diff = date.difference(startOfYear);
                          // var weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();

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
                                              dateForMonth.toString(), //todo: Month
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
                                    activityList: activitiesProvider.getActivities[index],
                                    modePriority: _modePriority,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Provider.of<Activities>(context, listen: true).isLoadingActivities == true
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: CircularProgressIndicator(),
                              ))
                          : SizedBox(),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}

class FullTime extends StatefulWidget {
  List activityList;
  bool modePriority;
  FullTime({Key key, @required this.activityList, @required this.modePriority}) : super(key: key);

  @override
  FullTimeState createState() => FullTimeState();
}

class FullTimeState extends State<FullTime> {
  double scaleHeight = 40;
  double check = 40;

  final _scrollController = ScrollController(initialScrollOffset: 800);
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
                      ActivityBox(context: context, myActivity: widget.activityList[x], height: scaleHeight / 60, modePriority: widget.modePriority, i:x),
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
        for (var m = 0; m < 7; m++) PlaceHolder(vertical: vertical),
//        placeHolder(vertical: vertical),
//        placeHolder(vertical: vertical),
//        placeHolder(vertical: vertical),
//        placeHolder(vertical: vertical),
//        placeHolder(vertical: vertical),
      ],
    ),
  );
}

class PlaceHolder extends StatelessWidget {
  PlaceHolder({@required this.vertical});
  final vertical;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      height: vertical,
      decoration: const BoxDecoration(
        border: const Border(
          right: const BorderSide(
            width: 1.0,
            color: const Color(0xFFE0E0E0),
          ),
        ),
      ),
    ));
  }
}

Widget placeHolder({@required double vertical}) {
  return Expanded(
      child: Container(
    height: vertical,
    decoration: const BoxDecoration(
      border: const Border(
        right: const BorderSide(
          width: 1.0,
          color: const Color(0xFFE0E0E0),
        ),
      ),
    ),
  ));
}
