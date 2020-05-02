import 'package:flutter/material.dart';
import 'MembersJoinRequests.dart' as JoinRequest;
import 'MembersUsers.dart' as MemberUsers;

void main() => runApp(MaterialApp(
  home: MemberPage(),
));

class MemberPage extends StatefulWidget{
  Members createState()=> Members();
}

class Members extends State<MemberPage> with SingleTickerProviderStateMixin  {
  String _ActivityName;
  double _discreteValue =10.0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TabController controller;
  @override
  void initState()
  {
    controller = new TabController(length: 3, vsync: this) ;
    super.initState();
  }

  @override
  void dispose()
  {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar (
        title: Text ( 'Contacts' ),
        backgroundColor: Colors.blue[600],
        bottom: new TabBar(
          indicatorColor: Colors.lime,
          controller: controller,
          tabs: <Widget>[
            new Tab(
              text: "Join Requests",
            ),
            new Tab(
              text: "Users",
            ),
            new Tab(
              text: "Groups",
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.location_on),
            title: new Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.date_range),
            title: new Text('Schedule'),
          )

        ],
      ),
      body:
      new TabBarView(
        controller: controller,
        children: <Widget>[
          new JoinRequest.MembersJoinRequests(),
          new MemberUsers.MembersUsers(),
          new Text("dasda")
        ],),

    );
  }



}
