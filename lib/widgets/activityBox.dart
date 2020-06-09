import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:optifyapp/screens/activity_screen.dart';
import 'package:random_color/random_color.dart';
import 'package:optifyapp/ActivityClass.dart';

class ActivityBox extends StatefulWidget {
  ActivityBox({@required this.context, @required this.myActivity, @required this.height});
  final BuildContext context;
  final myActivity, height;
  @override
  _ActivityBoxState createState() => _ActivityBoxState();
}

class _ActivityBoxState extends State<ActivityBox> {
  var startDate, endDate;
  var top, duration, horiz, vert;
  int priority;
  var weekDay;
  var fontSize;
  bool tapped = false;
  var left;
  bool deduced = false;

  @override
  void initState() {
    startDate = DateTime.parse(widget.myActivity["activity"]["start_times"][0].toString());
    endDate = DateTime.parse(widget.myActivity["activity"]["end_times"][0].toString());
    weekDay = startDate.weekday.toDouble();
    top = startDate.hour.toDouble() * 60 + startDate.minute.toDouble();
    duration = -startDate.hour.toDouble() * 60 + endDate.hour.toDouble() * 60 - startDate.minute.toDouble() + endDate.minute.toDouble();
    priority = int.parse(widget.myActivity["priority"].toString());
    horiz = 50.0;
    vert = top;
    fontSize = 12.0;
    left = 50.0 * weekDay;
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
      left: (tapped && (left + 100 > MediaQuery.of(context).size.width)) ? left - 150 : left,
      top: top * (widget.height),
      child: InkWell(
        onTap: () {
          setState(() => tapped = !tapped);
        },
        child: tapped
            ? Container(
                height: duration * (widget.height) < 100 ? 100 : duration * (widget.height),
                width: 200,
                child: Card(
                  elevation: 1,
                  child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.myActivity["activity"]["title"],
                                style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat.yMMMd().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString(),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString() +
                                      " - " +
                                      DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["end_times"][0])).toString(),
                                  style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.normal),
                                ),
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
                      Column(
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityScreen(myActivity: widget.myActivity)));
                              }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Transform.rotate(
                                  angle: 3.18,
                                  child: CircularProgressIndicator(
//                                          value: Tween<Double>(0.0, int.parse(_activity[i]["priority"].toString()).toDouble() / 100).animate(parent),
                                    value: int.parse(priority.toString()).toDouble() / 100,
                                    strokeWidth: 4,
                                    valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.lightGreen[priority * 9 - (priority * 9) % 100 + 100],
                                    ),
                                    backgroundColor: Colors.grey[100],
                                  ),
                                ),
                                Text(
                                  priority.toString(),
                                  style: TextStyle(color: Colors.grey[900], fontSize: 15, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

//                                    Image(
//                                      image: NetworkImage("https://img.icons8.com/wired/2x/passenger-with-baggage.png"),
//                                      height: 60,
//                                      width: 60,
//                                    ),
                    ],
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
//                  color: Colors.lightGreen[(priority * 9 - (priority * 9) % 100)],
                  color: Colors.lime[100],
//                  borderRadius: BorderRadius.circular(3),
////                  border: Border.all(color: Theme.of(context).primaryColor, width: .7),
                ),
                width: horiz,
                height: duration * (widget.height),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(1),
                child: Text(
                  widget.myActivity["activity"]["title"].toString(),
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                  ),
                ),
              ),
      ),
    );
  }
}

Widget activityBoxObject(context, myActivity, height) {
//  final RandomColor _randomColor = RandomColor();
  final DateTime startDate = DateTime.parse(myActivity["activity"]["start_times"][0].toString());
  final DateTime endDate = DateTime.parse(myActivity["activity"]["end_times"][0].toString());
  final weekDay = startDate.weekday.toDouble();
  final double top = startDate.hour.toDouble() * 60 + startDate.minute.toDouble();
  final double duration = -startDate.hour.toDouble() * 60 + endDate.hour.toDouble() * 60 - startDate.minute.toDouble() + endDate.minute.toDouble();
  final int priority = int.parse(myActivity["priority"].toString());
  double horiz = 50;
  double vert = top;

//  _randomColor.randomColor(colorBrightness: ColorBrightness.light);
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 50.0 * weekDay,
    top: top * (height),
    child: InkWell(
      onTap: () {
        horiz == 50 ? horiz = 100 : horiz = 50;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[priority * 9 - (priority * 9) % 100 + 100],
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Theme.of(context).primaryColor, width: .7),
        ),
        width: horiz,
        height: duration * (height),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1),
        child: Text(
          myActivity["activity"]["title"].toString(),
          overflow: TextOverflow.fade,
          softWrap: true,
          style: TextStyle(
            fontSize: 12.0,
          ),
        ),
      ),
    ),
  );
}

Widget activityBox({
  @required final double height,
  @required final double duration,
  @required final double days,
  @required final double startday,
  @required final double starttime,
  @required final String name,
  @required final String description,
}) {
  final RandomColor _randomColor = RandomColor();

  Color _color = _randomColor.randomColor(colorBrightness: ColorBrightness.light);
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 48 * startday,
    top: height * 60 * (starttime - 8),
    height: height * duration,
    width: days * 48,
    child: Opacity(
      opacity: .9,
      child: Card(
        color: _color,
        elevation: 1,
        margin: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Container(
                  child: new LayoutBuilder(builder: (context, constraint) {
                    return new Icon(Icons.library_books, size: constraint.biggest.width - 20);
                  }),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(name, style: TextStyle(fontSize: 26.0)),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
