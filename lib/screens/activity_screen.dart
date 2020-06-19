import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:optifyapp/ActivityClass.dart';
import 'package:optifyapp/providers/activities.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = '/activity';

  var myActivity, i;
  ActivityScreen({this.myActivity, this.i});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String token, schedule_id;

  @override
  Widget build(BuildContext context) {
    if (token == null || schedule_id == null) {
      token = Provider.of<Auth>(context).myToken;
      schedule_id = Provider.of<Auth>(context).myScheduleId;
    }
    return Scaffold(
//        backgroundColor: Colors.black12,
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
              elevation: 10,
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.myActivity["activity"]["title"],
                      style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          "Privacy:",
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
                          widget.myActivity["privacy"]["privacy"].toString()[0].toUpperCase() +
                              widget.myActivity["privacy"]["privacy"]
                                  .toString()
                                  .substring(1, widget.myActivity["privacy"]["privacy"].toString().length),
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
                          "Category:",
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
                          widget.myActivity["category"],
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
                          "Owner:",
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
                              backgroundColor: Colors.green.shade50,
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade100,
                                child: Text(widget.myActivity["activity"]["attendees"][0]["first_name"][0] +
                                    widget.myActivity["activity"]["attendees"][0]["last_name"][0]),
                              ),
                              label: Text(widget.myActivity["activity"]["attendees"][0]["first_name"] +
                                  " " +
                                  widget.myActivity["activity"]["attendees"][0]["last_name"]), //todo fix Name
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
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: Text(
                              "Do you want to remove this activity?",
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('No.'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes!',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    )),
                                onPressed: () {
                                  Provider.of<Activities>(context).removeActivity(schedule_id, widget.myActivity["activity"]["id"], widget.i, token);
                                  Navigator.of(ctx).pop();
                                  Navigator.of(ctx).pop();
                                  Flushbar(
                                    title: "Done!",
                                    message: "Activity was deleted",
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                                    borderRadius: 10,
                                    duration: Duration(seconds: 3),
                                  )..show(context);
                                },
                              ),
                            ],
                          ),
                        );
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
