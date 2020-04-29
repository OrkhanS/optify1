import 'dart:convert';
import 'dart:io';
import 'widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/activityListElement.dart';
import 'routes.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:optifyapp/ActivityClass.dart';

void main() => runApp(App());

Map<String, double> dataMap = new Map();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ActivityListScreen(),
    );
  }
}




class ActivityListScreen extends StatefulWidget {

  @override
  _ActivityListScreenState createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {

  List<Activity> _activity = List<Activity>();


  Future<List<Activity>> fetchActivities() async {

    var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
    const url =
        'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/';
    http.Response response = await http.get(
      url,
      headers: {
        HttpHeaders.CONTENT_TYPE: "application/json",
        "Authorization": "Token " + token,
      },
    );

    var activity = List<Activity>();

    if (response.statusCode == 200) {
      var ActivityForAdd = json.decode(response.body);
      for (var ActivityJson in ActivityForAdd) {
        var some = Activity.fromJson(ActivityJson);
        activity.add(some);
      }
    }
      /*for (var x in activity){
        dataMap.putIfAbsent(x.title,  () => double.parse(x.duration));
      }*/
    return activity;
  }

  @override
  void initState() {
    fetchActivities().then((value) {
      setState(() {
        _activity.addAll(value);

      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      floatingActionButton: AnimatedFloatingActionButton(
        //Fab list
          fabButtons: <Widget>[float1(context), float2()],
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close //To principal button
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Text("Activity List"),
      ),
      body: ListView(


        //final item = _activity[index];

          children: <Widget>[
            for (int i = _activity.length - 1; i >= 0; i--)
              Dismissible(
                // Each Dismissible must contain a Key. Keys allow Flutter to
                // uniquely identify widgets.
                  key: Key(_activity[i].id),
                  // Provide a function that tells the app
                  // what to do after an item has been swiped away.
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    setState(() {
                      var token = "d5c2711bdf2d1bf83000d86fe518887483dd1eb5";
                      var url2 =
                          'http://optify-dev.us-west-2.elasticbeanstalk.com/api/schedules/1/activities/' +
                              _activity[i].id.toString()+
                              '/';
                      print(url2);
                      http.delete(
                        url2,
                        headers: {
                          HttpHeaders.CONTENT_TYPE: "application/json",
                          "Authorization": "Token " + token,
                        },
                      ).then((response) {
                        print(response.body);
                      });
                    });
                    _activity.removeAt(i);

                    // Then show a snackbar.
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text(" dismissed")));
                  },
                  // Show a red background as the item is swiped away.
                  background: Container( padding:EdgeInsets.all(40),color: Colors.red, child: Text("Delete                    Delete",style: TextStyle(color: Colors.white,fontSize: 30),),),
                  child: Card(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    elevation: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                            height: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _activity[i].title,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Text('Time: ' +
                                    _activity[i]
                                        .start_times
                                        .substring(12, 17) +
                                    " - " +
                                    _activity[i].end_times.substring(12, 17)),
                                Text('Priority: ' + _activity[i].priority),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            height: 80,
                            child: Image.network(
                                'https://www.nhs-health-trainers.co.uk/wp-content/uploads/2019/05/physical-activity.jpg'),
                          ),
                        ),
                      ],
                    ),
                  ))
          ]),

    );
  }
}

Widget float1(context) {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn1",
      onPressed: (){
        navigateToAddActivity(context);
      },
      tooltip: 'First button',
      child: Icon(Icons.add),

    ),
  );
}

Widget float2() {
  return Container(
    child: FloatingActionButton(
      heroTag: "btn2",
      onPressed: null,
      tooltip: 'Second button',
      child: Icon(Icons.edit),
    ),
  );
}
