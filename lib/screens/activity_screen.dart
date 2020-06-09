import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = '/activity';

  var myActivity;
  ActivityScreen({this.myActivity});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            color: Theme.of(context).primaryColor,
            iconSize: 30,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Activity",
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
          ),
          elevation: 1,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height * .8,
          child: Center(
            child: Card(
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(),
                    Text(
                      widget.myActivity["activity"]["title"],
                      style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          "Date:",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          "Start Time:",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["start_times"][0])).toString(),
                            style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          "End Time:",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: DateFormat.Hm().format(DateTime.parse(widget.myActivity["activity"]["end_times"][0])).toString(),
                            style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          "Members:",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade800,
                                child: Text('KS'),
                              ),
                              label: Text('Kazato Suriname'), //todo fix Name
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    RaisedButton(
                      color: Colors.red,
                      onPressed: () {
                        //todo Delete activity
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete Activity",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
