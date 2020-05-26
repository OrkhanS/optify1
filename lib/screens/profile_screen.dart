import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Auth auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<Auth>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Profile",
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              MdiIcons.logoutVariant,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
//                          title: Text(''),
                  content: Text(
                    "Are you sure you want to Log out?",
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No.'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Yes, let me out!',
                          style: TextStyle(
                            color: Colors.redAccent,
                          )),
                      onPressed: () {
                        Provider.of<Auth>(context, listen: false).logout(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            width: 4,
          )
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage("https://robohash.org/" + auth.token.toString()), //Todo
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                            ),
                            Text(
//                              "  " +
//                                  Provider.of<Auth>(context, listen: false).userdetail["first_name"].toString() +
//                                  " " +
//                                  Provider.of<Auth>(context, listen: false).userdetail["last_name"].toString(),
                              "Kazato Suriname",
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
                            ),
                            Text(
                              Provider.of<Auth>(context, listen: false).userdetail["email"].toString(),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey[600],
                      height: 50,
                    ),
                    ListTile(
                      dense: true,
                      title: Text(
                        "Phone: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Text(
                        "+994773121200", // todo add user's num
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
