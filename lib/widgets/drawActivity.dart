import 'package:flutter/material.dart';

Widget drawActivity({@required final double height}) {
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    curve: Curves.decelerate,
    left: 50,
    height: height * 2,
    width: 235,
    child: Opacity(
      opacity: .9,
      child: Card(
        color: Colors.yellow[200],
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
                    Text("Work", style: TextStyle(fontSize: 26.0)),
                    Text(
                      "METU NCC 2nd dorm",
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
