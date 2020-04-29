import 'package:flutter/material.dart';
void main() => runApp(MaterialApp(
  home: MembersJoinRequests(),
));

class MembersJoinRequests extends StatefulWidget{
  MembersJoinRequestsPage createState()=> MembersJoinRequestsPage();
}

class MembersJoinRequestsPage extends State<MembersJoinRequests> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body:

        new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _formKey,
              child: FormUI(),
            ),
          ),
        )
        ,

      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[

        new Row(
          children: <Widget>[
            Container(
                 child: Column(children: <Widget>[
                    Container( margin: EdgeInsets.only(right: 250.0, top: 10.0),
                      child: new Text(
                          "My Contacts\n",
                          style: TextStyle(fontSize: 19.0,),
                      ),

                      ),

                    Container(
                        child: new Row(
                          children: <Widget>[
                            Container( margin: EdgeInsets.only(top: 5.0,left: 15.0),
                              child: new Text("Name"),
                            ),
                            Container(margin: EdgeInsets.only(left: 245.0),
                              child: new Text("Accept"),
                            ),
                            Container( margin: EdgeInsets.only(left: 10.0),
                              child: new Text("Kick"),
                            ),
                          ],
                      ),
                      ),

                    Container( margin: EdgeInsets.only(left: 285.0),
                         child: new Row(
                              children: <Widget>[
                                 Container(
                                     child: new Radio(value: 1, groupValue: null, onChanged: null)
                                 ),
                                Container(
                                    child: new Radio(value: 1, groupValue: null, onChanged: null)
                                ),
                         ],
                          )
                      ),
                    ],
                 ),

            ),

          ]
        ),

        new Row(
          children: <Widget>[

            Container(
              child: Column(children: <Widget>[
                Container( margin: EdgeInsets.only(right: 300.0, top: 30.0),
                  child: new Text(
                    "Others\n",
                    style: TextStyle(fontSize: 19.0,),
                  ),

                ),

                Container(
                  child: new Row(
                    children: <Widget>[
                      Container( margin: EdgeInsets.only(top: 5.0, left: 15.0),
                        child: new Text("Name"),
                      ),
                      Container(margin: EdgeInsets.only(left: 245.0),
                        child: new Text("Accept"),
                      ),
                      Container( margin: EdgeInsets.only(left: 10.0),
                        child: new Text("Kick"),
                      ),
                    ],
                  ),
                ),

                Container( margin: EdgeInsets.only(left: 285.0),
                    child: new Row(
                      children: <Widget>[
                        Container(
                            child: new Radio(value: 1, groupValue: null, onChanged: null)
                        ),
                        Container(
                            child: new Radio(value: 1, groupValue: null, onChanged: null)
                        ),
                      ],
                    )
                ),
              ],
              ),

            ),

          ],

        ),




        new Row(
          children: <Widget>[

            Container(margin: EdgeInsets.only(left: 150, top: 100),
                child: new RaisedButton(
                  onPressed: () {}, color: Colors.teal,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text('Save'),
                      new Icon(Icons.save),

                    ],
                  ),
                ),
            ),

          ],
        ),
      ],

    );
  }
}