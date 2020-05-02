import 'package:flutter/material.dart';
import 'NewActivityJoint.dart' as joint;
import 'newActivityPersonal.dart' as personal;

void main() => runApp(MaterialApp(
      home: NewActivityPage(),
    ));

class NewActivityPage extends StatefulWidget {
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
    controller = new TabController(length: 2, vsync: this);
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
        title: Text('New Activity'),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: new TabBar(
          indicatorColor: Colors.white,
          controller: controller,
//          unselectedLabelColor: Theme.of(context).primaryColorDark,

          tabs: <Widget>[
            new Tab(
              text: "Personal",
            ),
            new Tab(
              text: "Joint",
            )
          ],
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[new personal.newActivityPersonal(), new joint.NewActivityJoint()],
      ),
    );
  }
}
