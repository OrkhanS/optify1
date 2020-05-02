import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:optifyapp/ActivityClass.dart';

Widget activityBoxObject(Activity myActivity,height) {
  final RandomColor _randomColor = RandomColor();
  DateTime date = DateTime.parse(myActivity.start_times.substring(1,20));
  double hour = double.parse(myActivity.start_times.substring(12,14));
  double minute = double.parse(myActivity.start_times.substring(15,17))/60.0;
//  Color _color =
//  _randomColor.randomColor(colorBrightness: ColorBrightness.light);
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 48.0 * date.weekday,
    top: height * 60.0 * (hour + minute - 8.0),
    height: height * (double.parse(myActivity.duration.toString().substring(1,3))*60 + double.parse(myActivity.duration.toString().substring(4,6))),
    width: 1.0 * 52,
    child: Opacity(
      opacity: .9,
      child: Card(
        color: Colors.lightGreen[int.parse(myActivity.priority)*9-(int.parse(myActivity.priority)*9)%100+100],
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
                    Text(myActivity.title, style: TextStyle(fontSize: 10.0)),
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

  Color _color =
      _randomColor.randomColor(colorBrightness: ColorBrightness.light);
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
                    return new Icon(Icons.library_books,
                        size: constraint.biggest.width - 20);
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
