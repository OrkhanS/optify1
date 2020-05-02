import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'members.dart';
import 'package:optifyapp/providers/users.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'login.dart';
import 'routes.dart';

void main() => runApp(MaterialApp(
      home: SignUpPage(),
    ));

class SignUpPage extends StatefulWidget {
  SignUp createState() => SignUp();
}

class SignUp extends State<SignUpPage> {
  String _username;
  String _password;
  String _lastName;
  String _firstName;
  String _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[50],
        appBar: AppBar(
          title: Text('Registration'),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: FormUI(),
            ),
          ),
        ));
  }

  Widget FormUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Image.asset('Assets/optify.png'),
          height: 170.0,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Username'),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            this.setState(() {
              _username = value;
            });
          },
        ),
        new TextFormField(
          decoration: const InputDecoration(labelText: 'First Name'),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            this.setState(() {
              _firstName = value;
            });
          },
        ),
        new TextFormField(
          decoration: const InputDecoration(labelText: 'Last Name'),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            this.setState(() {
              _lastName = value;
            });
          },
        ),
        new TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              _email = value;
            });
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          keyboardType: TextInputType.visiblePassword,
          validator: (String arg) {
            if (arg.length < 6)
              return 'Password Must be at least 6 characters';
            else
              return null;
          },
          onChanged: (value) {
            setState(() {
              _password = value;
            });
          },
        ),
        new SizedBox(
          height: 10.0,
        ),
        Container(
          margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: new SizedBox(
            height: 50.0,
            width: 150.0,
            child: RaisedButton(
              color: Colors.white,
              shape: StadiumBorder(),
              child: new Text('Sign Up'),
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                // This is API part
                const url = 'http://optify-dev.us-west-2.elasticbeanstalk.com/api/users/';
                http
                    .post(url,
                        headers: {HttpHeaders.CONTENT_TYPE: "application/json"},
                        body: json.encode({
                          "username": _username,
                          "password": _password,
                          "first_name": _firstName,
                          "last_name": _lastName,
                          "email": _email,
                        }))
                    .then((response) {
                  if (response.statusCode == 201) {
//                    navigateToLogin(context);
                  } else {
                    final snackBar = SnackBar(content: Text('Wrong creditentials, try again'));
                  }
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 20.0),
              child: RaisedButton(
                padding: EdgeInsets.all(0.0),
                child: Container(
                  child: Image.asset('Assets/loginFB.png'),
                ),
                onPressed: () {},
                shape: StadiumBorder(),
              ),
            ),
            Container(
              child: RaisedButton(
                padding: EdgeInsets.all(0.0),
                child: Container(
                  child: Image.asset('Assets/logingGoogle.png'),
                ),
                onPressed: () {},
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
