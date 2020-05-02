import 'package:flutter/material.dart';
void main() => runApp(MaterialApp(
  home: MembersUsers(),
));

class MembersUsers extends StatefulWidget{
  MembersUsersPage createState()=> MembersUsersPage();
}

class MembersUsersPage extends State<MembersUsers> {
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
                  Container( margin: EdgeInsets.only(top: 10.0),
                    child: new Text(
                      "My Groups\n",
                      style: TextStyle(fontSize: 19.0,),
                    ),

                  ),

                  Container(
                    child: new Row(
                      children: <Widget>[
                        Container( margin: EdgeInsets.only(top: 5.0,left: 15.0),
                          child: new Text("Name"),
                        ),
                        Container( margin: EdgeInsets.only(left: 260.0),
                            child: new Radio(value: 1, groupValue: null, onChanged: null)
                        ),
                      ],
                    ),
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
                Container( margin: EdgeInsets.only(top: 30.0),
                  child: new Text(
                    "My Contacts\n",
                    style: TextStyle(fontSize: 19.0,),
                  ),

                ),

                Container(
                  child: new Row(
                    children: <Widget>[
                      Container( margin: EdgeInsets.only(top: 5.0, left: 15.0),
                        child: new Text("Name"),
                      ),
                      Container( margin: EdgeInsets.only(left: 260.0),
                          child: new Radio(value: 1, groupValue: null, onChanged: null)
                      ),
                    ],
                  ),
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
                    new Text('Invite'),
                    new Icon(Icons.group_add),

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