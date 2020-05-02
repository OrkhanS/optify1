import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:optifyapp/screens/account_screen.dart';

class ContactsScreen extends StatelessWidget {
  static const routeName = '/social/contacts';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.grey[600],
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Contacts",
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
                  Container(
                    height: 50,
                    width: 50,
                    color: Colors.blueGrey,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
