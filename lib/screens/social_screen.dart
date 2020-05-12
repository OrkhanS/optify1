import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/screens/account_screen.dart';

class SocialScreen extends StatefulWidget {
  static const routeName = '/social';
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Social",
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 1,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Column(
                children: <Widget>[
//                  Row(
//                    children: <Widget>[
//                      SocialCard(
//                        context,
//                        "Contacts",
//                        Icon(
//                          MdiIcons.humanGreeting,
//                          size: 30,
//                          color: Colors.grey[700],
//                        ),
//                        '/social/contacts',
//                      ),
//                      SocialCard(
//                        context,
//                        "Groups",
//                        Icon(
//                          MdiIcons.humanMaleFemale,
//                          size: 30,
//                          color: Colors.grey[700],
//                        ),
//                        '/social/contacts',
//                      ),
//                    ],
//                  ),
//                  Row(
//                    children: <Widget>[
//                      SocialCard(
//                        context,
//                        "Chats",
//                        Icon(
//                          MdiIcons.forum,
//                          size: 30,
//                          color: Colors.grey[700],
//                        ),
//                        '/social/chatsscreen',
//                      ),
//                    ],
//                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

Widget SocialCard(_ctx, String _name, Icon _locIcon, String _route) {
  return Expanded(
    flex: 1,
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(_ctx, _route);
      },
      child: Card(
        elevation: 3,
        child: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                _name,
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w400,
                ),
              ),
              _locIcon,
            ],
          ),
        ),
      ),
    ),
  );
}
