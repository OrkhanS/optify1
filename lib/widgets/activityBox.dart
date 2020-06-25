import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:optifyapp/models/routine_color.dart';
import 'package:optifyapp/screens/activity_screen.dart';

class ActivityBox extends StatefulWidget {
  var i;
  ActivityBox({@required this.context, @required this.myActivity, @required this.height, @required this.modePriority, this.i});
  final BuildContext context;
  final myActivity, height;
  final bool modePriority;
  @override
  _ActivityBoxState createState() => _ActivityBoxState();
}

class _ActivityBoxState extends State<ActivityBox> {
  var startDate, endDate;
  var top, duration, horiz, vert;
  int priority;
  var weekDay;
  var fontSize;
  bool tapped;
  var left;
  bool deduced;
  Color boxColor;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(widget.myActivity["activity"]["start_times"][0].toString());
    endDate = DateTime.parse(widget.myActivity["activity"]["end_times"][0].toString());
    weekDay = startDate.weekday.toDouble();
    top = startDate.hour.toDouble() * 60 + startDate.minute.toDouble();
    duration = -startDate.hour.toDouble() * 60 + endDate.hour.toDouble() * 60 - startDate.minute.toDouble() + endDate.minute.toDouble();
    priority = int.parse(widget.myActivity["priority"].toString());
    tapped = false;
    deduced = false;
    horiz = 50.0;
    vert = top;
    fontSize = 12.0;
    left = 49.5 * weekDay;
    boxColor = widget.modePriority ? Colors.lightGreen[(priority * 9 - (priority * 9) % 100)] : routineColor[widget.myActivity["category"]];
  }

  @override
  void didChangeDependencies() {
    boxColor = widget.modePriority ? Colors.lightGreen[(priority * 9 - (priority * 9) % 100)] : routineColor[widget.myActivity["category"]];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext ctx) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
      left: (tapped && (left + 200 > MediaQuery.of(context).size.width)) ? left - (left + 220 - MediaQuery.of(context).size.width) : left,
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
                  elevation: 3,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      widget.myActivity["activity"]["title"],
                                      overflow: TextOverflow.fade,
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 19, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.myActivity["category"],
                                style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.normal),
                              ),
                              Text(
                                DateFormat.yMMMd().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString(),
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString() +
                                      " - " +
                                      DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["end_times"][0])).toString(),
                                  style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => ActivityScreen(i: widget.i, myActivity: widget.myActivity)));
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
                          SizedBox(),
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
                  color: boxColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: Colors.black26
//                  Theme.of(context).primaryColor
                      ,
                      width: .5),
                ),
                width: horiz - 3,
                height: duration * (widget.height),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(1),
                child: Text(
                  widget.myActivity["activity"]["title"].toString(),
                  textAlign: TextAlign.center,
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
