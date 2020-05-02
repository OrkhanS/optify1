//import 'dart:convert';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'members.dart';
//import 'NewActivityMain.dart';
//import 'package:http/http.dart' as http;
//import 'dart:io';
//import 'ScheduleScreen.dart';
//import 'routes.dart';
//import 'package:optifyapp/MainSchedule.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//void main() => runApp(MaterialApp(
//      home: LoginPage(),
//    ));
//
//class LoginPage extends StatefulWidget {
//  Login createState() => Login();
//}
//
//class Login extends State<LoginPage> {
//  String _username;
//  String _password;
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  bool _autoValidate = false;
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      theme: Theme.of(context),
//      home: Scaffold(
//        backgroundColor: Colors.teal[50],
//        appBar: AppBar(
//          title: Text('Login'),
//          backgroundColor: Theme.of(context).primaryColor,
//          centerTitle: false,
//        ),
//        body: Builder(
//            // Create an inner BuildContext so that the onPressed methods
//            // can refer to the Scaffold with Scaffold.of().
//            builder: (BuildContext context) {
//          return SingleChildScrollView(
//            child: Container(
//              margin: EdgeInsets.all(15.0),
//              child: Form(
//                key: _formKey,
//                autovalidate: _autoValidate,
//                child: Container(
//                  child: Center(
//                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
//                        Container(
//                          child: Image.asset('Assets/optify.png'),
//                          height: 250.0,
//                          margin: EdgeInsets.only(bottom: 20),
//                        ),
//                        TextFormField(
//                          decoration:
//                              const InputDecoration(labelText: 'Username'),
//                          keyboardType: TextInputType.text,
//                          onChanged: (val) {
//                            _username = val;
//                          },
//                        ),
//                        TextFormField(
//                          decoration:
//                              const InputDecoration(labelText: 'Password'),
//                          keyboardType: TextInputType.visiblePassword,
//                          obscureText: true,
//                          validator: (String arg) {
//                            if (arg.length < 6)
//                              return 'Password Must be at least 6 characters';
//                            else
//                              return null;
//                          },
//                          onChanged: (String val) {
//                            _password = val;
//                          },
//                        ),
//                        Container(
//                          margin: EdgeInsets.only(top: 30, bottom: 100),
//                          child: SizedBox(
//                            height: 50.0,
//                            width: 150.0,
//                            child: RaisedButton(
//                              shape: RoundedRectangleBorder(
//                                borderRadius: new BorderRadius.circular(18.0),
//                              ),
//                              child: Text('Login'),
//                              padding: EdgeInsets.all(8.0),
//                              color: Colors.white,
//                              onPressed: () {
//                                const url =
//                                    'http://optify-dev.us-west-2.elasticbeanstalk.com/api/api-token-auth/';
//
//                                http
//                                    .post(url,
//                                        headers: {
//                                          HttpHeaders.CONTENT_TYPE:
//                                              "application/json"
//                                        },
//                                        body: json.encode({
//                                          "username": _username,
//                                          "password": _password,
//                                        }))
//                                    .then((response) {
//                                  if (json.decode(response.body)["token"] !=
//                                      null) {
//                                    print("success");
////                                  final snackBar =
////                                      SnackBar(content: Text('Logged In'));
////
////                                  Scaffold.of(context).showSnackBar(snackBar);
//                                    _save(json.decode(response.body)["token"]);
//                                    Navigator.push(
//                                        context,
//                                        MaterialPageRoute(
//                                            builder: (context) =>
//                                                ScheduleScreen()));
//                                  } else {
//                                    print("failed");
//                                    final snackBar = SnackBar(
//                                        content: Text('Wrong creditentials'));
//
//                                    Scaffold.of(context).showSnackBar(snackBar);
//                                  }
//                                });
//                              },
//                            ),
//                          ),
//                        ),
//
//                        /*   RaisedButton(
//                child:  Text('Members'),
//                onPressed: () {
//                  navigateToMembers(context);
//                },
//              ),
//               RaisedButton(
//                child:  Text(' Activity'),
//                onPressed: () {
//                  navigateToActivity(context);
//                },
//              ),*/
//
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Container(
//                              margin: EdgeInsets.only(right: 15),
//                              child: RaisedButton(
//                                padding: EdgeInsets.all(0.0),
//                                child: Container(
//                                  child: Image.asset('Assets/loginFB.png'),
//                                ),
//                                onPressed: () {},
//                                shape: StadiumBorder(),
//                              ),
//                            ),
//                            Container(
//                              margin: EdgeInsets.only(bottom: 0),
//                              child: RaisedButton(
//                                padding: EdgeInsets.all(0.0),
//                                child: Container(
//                                  child: Image.asset('Assets/logingGoogle.png'),
//                                ),
//                                onPressed: () {},
//                                shape: StadiumBorder(),
//                              ),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          );
//        }),
//      ),
//    );
//  }
//
//  void _validateInputs() {
//    if (_formKey.currentState.validate()) {
//      _formKey.currentState.save();
//    } else {
//      setState(() {
//        _autoValidate = true;
//      });
//    }
//  }
//}
//
//_save(token) async {
//  final prefs = await SharedPreferences.getInstance();
//  final key = 'UserToken';
//  final value = token;
//  print("SALAM QAQA VALLAH");
//  prefs.setInt(key, value);
//  print('saved $value');
//  print("HE ALLAH HAQQI");
//}
