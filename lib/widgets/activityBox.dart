import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:optifyapp/ActivityClass.dart';

Widget activityBoxObject(myActivity, height) {
//  final RandomColor _randomColor = RandomColor();
  final DateTime startDate = DateTime.parse(myActivity["activity"]["start_times"][0].toString());
  final DateTime endDate = DateTime.parse(myActivity["activity"]["end_times"][0].toString());
  final double weekDay = startDate.weekday.toDouble();
  final double top = startDate.hour.toDouble() * 60 + startDate.minute.toDouble();
  final double duration = -startDate.hour.toDouble() * 60 + endDate.hour.toDouble() * 60 - startDate.minute.toDouble() + endDate.minute.toDouble();
  final int priority = int.parse(myActivity["priority"].toString());

//  _randomColor.randomColor(colorBrightness: ColorBrightness.light);
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 50.0 * weekDay,
    top: top * height,
    height: duration * height,
    width: 57.0 * 1.0,
    child: Opacity(
      opacity: .9,
      child: Card(
        color: Colors.lightGreen[priority * 9 - (priority * 9) % 100 + 100],
        elevation: 5,
        margin: const EdgeInsets.all(5),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
//              Flexible(
//                fit: FlexFit.tight,
//                flex: 1,
//                child: Container(
//                  child: new LayoutBuilder(builder: (context, constraint) {
//                    return new Icon(Icons.library_books,
//                        size: constraint.biggest.width - 20);
//                  }),
//                ),
//              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(myActivity["activity"]["title"].toString(), style: TextStyle(fontSize: 10.0)),
//                    Text(
//                      "description",
//                      style: TextStyle(fontSize: 12.0),
//                    ),
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
