import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:optifyapp/ActivityClass.dart';

Widget activityBoxObject(myActivity, height) {
  final RandomColor _randomColor = RandomColor();
  DateTime date = DateTime.parse(myActivity["activity"]["start_times"][0].toString());
  DateTime endDate = DateTime.parse(myActivity["activity"]["end_times"][0].toString());
  double hour = date.hour.toDouble();
  double minute = date.minute.toDouble();
  double weekDay = date.weekday.toDouble();
  double height1;
  double height2;
  if(myActivity["activity"]["durations"][0].toString().length > 8){
    height1 = double.parse(myActivity["activity"]["durations"][0].toString().substring(2, 4));
    height2 =  double.parse(myActivity["activity"]["durations"][0].toString().substring(5,7));
  }else{
    height1 = double.parse(myActivity["activity"]["durations"][0].toString().substring(0, 2));
    height2 =  double.parse(myActivity["activity"]["durations"][0].toString().substring(3,5));
  }
  int priority = int.parse(myActivity["priority"].toString());
  
//  _randomColor.randomColor(colorBrightness: ColorBrightness.light);
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 48.0 * weekDay,
    top: height * 60.0 * (hour + minute - 8.0),
    height: height *
        (height1 * 60 +
            height2),
    width: 1.0 * 52,
    child: Opacity(
      opacity: .9,
      child: Card(
        color: Colors.lightGreen[ priority * 9 - (priority * 9) % 100 + 100],
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