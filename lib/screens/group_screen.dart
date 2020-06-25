import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:optifyapp/widgets/activityBox.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = '/group';
  var group, provider;
  GroupScreen({@required this.group, @required this.provider});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Group",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.group["name"].toString(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                              ),
                              for (var x in widget.group["groupmembers"])
                                Text(
                                  "@" + x["member"]["username"].toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage("https://robohash.org/" + widget.group["name"].toString()), //Todo
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Text(
                "Schedule",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
//              width: MediaQuery.of(context).size.width * 0.8,
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
                                width: 1.0,
                                color: Colors.grey[100],
                              ),
                              right: BorderSide(
                                width: 1.0,
                                color: Colors.grey[100],
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                "July", //todo: Month
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "15 - 21", //todo :Range
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
//                                                fontWeight: FontWeight.bold,
                                ),
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
                      activityList: widget.provider.groupActivity,
                      modePriority: true,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FullTime extends StatefulWidget {
  final List activityList;
  final bool modePriority;
  FullTime({
    Key key,
    @required this.activityList,
    @required this.modePriority,
  }) : super(key: key);
  @override
  FullTimeState createState() => FullTimeState();
}

class FullTimeState extends State<FullTime> {
  double scaleHeight = 40;
  double check = 40;

  final _scrollController = ScrollController(initialScrollOffset: 800);
  @override
  Widget build(BuildContext context) {
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

                  if (widget.activityList != null && widget.activityList.length != 0)
                    for (var x = widget.activityList.length - 1; x >= 0; x--)
                      ActivityBox(
                          context: context, myActivity: widget.activityList[x], height: scaleHeight / 60, modePriority: widget.modePriority, i: x),
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
