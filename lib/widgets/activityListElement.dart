import 'package:flutter/material.dart';
import 'package:optifyapp/ActivityClass.dart';
Widget activityListElement({
  @required final Activity activity }
    ) {
  return Card(
    margin: EdgeInsets.fromLTRB(10, 10, 10,

        10),
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
                Text(activity.title,style: TextStyle(fontSize: 20,),),

                Text('Time: ' +activity.start_times.substring(12,17)+ " - " + activity.end_times.substring(12,17)),
                Text('Priority: ' + activity.priority),
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
  );
}
