import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NewActivityJoint.dart' as joint;
import 'newActivityPersonal.dart' as personal;

void main() => runApp(MaterialApp(
      home: NewActivityPage(),
    ));

class NewActivityPage extends StatefulWidget {
  var token, schedule_id;
  NewActivityPage({this.token, this.schedule_id});
  NewActivityMain createState() => NewActivityMain();
}

class NewActivityMain extends State<NewActivityPage> with SingleTickerProviderStateMixin {
  String _ActivityName;
  double _discreteValue = 10.0;
  DateTime _dateTime;
  TimeOfDay _time; //After we get time, add it into FROM and UNTIL section below, no need to ask it again below
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TabController controller;
  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.chevron_left,
            size: 30,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Add Activity',
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          indicatorColor: Colors.lime,
          controller: controller,
          tabs: <Widget>[
            Tab(
              child: Text(
                "Personal",
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            Tab(
              child: Text(
                "Joint",
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: <Widget>[personal.newActivityPersonal(token: widget.token, schedule_id: widget.schedule_id), joint.NewActivityJoint()],
      ),
    );
  }
}
