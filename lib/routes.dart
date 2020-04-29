import 'package:flutter/material.dart';
import 'package:optifyapp/login.dart';
import 'package:optifyapp/screens/schedule_screen.dart';
import 'package:optifyapp/main.dart';
import 'package:optifyapp/members.dart';
import 'package:optifyapp/MembersJoinRequests.dart';
import 'package:optifyapp/NewActivityJoint.dart';
import 'package:optifyapp/MembersUsers.dart';
import 'package:optifyapp/signup.dart';
import 'package:optifyapp/MapScreen.dart';
import 'newActivityMain.dart';
//import 'package:optifyapp/MainSchedule.dart';

//void navigateToLogin(BuildContext context) {
//  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
//}

void navigateToSignUp(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
}

//void navigateToSchedule(BuildContext context) {
//  Navigator.push(context, MaterialPageRoute(builder: (context) => MainSchedule()));
//}

navigateToMembers(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MemberPage()));
}

void navigateToProfile(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleScreen()));
}

void navigateToMapScreen(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
}

void navigateToAddActivity(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => NewActivityPage()));
}
