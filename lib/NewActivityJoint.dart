import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: NewActivityJoint(),
    ));

class NewActivityJoint extends StatefulWidget {
  NewActivityJointPage createState() => NewActivityJointPage();
}

class NewActivityJointPage extends State<NewActivityJoint> with SingleTickerProviderStateMixin {
  String _ActivityName;
  double _discreteValue = 10.0;
  DateTime _dateTime;
  TimeOfDay _time; //After we get time, add it into FROM and UNTIL section below, no need to ask it again below
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _formKey,
            child: FormUI(),
          ),
        ),
      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        Container(
          width: 320.0,
          child: new TextFormField(
            decoration: const InputDecoration(labelText: 'Activity Name'),
            keyboardType: TextInputType.text,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 100.0,
          height: 40.0,
          child: new RaisedButton(
            child: Text('Members'),
            onPressed: () {},
          ),
        ),
        new Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30.0, top: 30.0),
              width: 100.0,
              height: 60.0,
              child: new RaisedButton(
                child: Text('Start Date'),
                onPressed: () {
                  showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                    _time = time;
                  });
                  showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2222)).then((date) {
                    _dateTime = date;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 80.0, top: 30.0),
              width: 100.0,
              height: 60.0,
              child: new RaisedButton(
                child: Text('End Date'),
                onPressed: () {
                  showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
                    _time = time;
                  });
                  showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2222)).then((date) {
                    _dateTime = date;
                  });
                },
              ),
            ),
          ],
        ),
        Container(margin: EdgeInsets.only(top: 40.0), child: const Text('Priority')),
        new Slider(
          value: _discreteValue,
          min: 0.0,
          max: 100.0,
          divisions: 100,
          label: '${_discreteValue.round()}',
          onChanged: (double value) {
            setState(() {
              _discreteValue = value;
            });
          },
        ),
        new Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30.0, top: 30.0),
              width: 100.0,
              height: 60.0,
              child: new DropdownButton<String>(
                hint: new Text("Monthly"),
                items: <String>['Montly', 'Weekly', 'Daily'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 80.0, top: 30.0),
              width: 125.0,
              height: 60.0,
              child: new DropdownButton<String>(
                hint: Text('Education'),
                items: <String>['Work', 'Recriational', 'Entertainment', 'Education', 'Social'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        new Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30.0, top: 20.0),
              width: 100.0,
              height: 60.0,
              child: new RaisedButton(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  child: Text('From'),
                ),
                onPressed: () {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 80.0, top: 20.0),
              width: 100.0,
              height: 60.0,
              child: new RaisedButton(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  child: Text('Until'),
                ),
                onPressed: () {},
              ),
            ),
            Container(
                width: 50.0,
                height: 50.0,
                margin: EdgeInsets.only(left: 20.0, top: 75.0),
                child: new FloatingActionButton(
                  onPressed: () {},
                  tooltip: 'Save',
                  child: Icon(Icons.save),
                )),
          ],
        ),
      ],
    );
  }
}
