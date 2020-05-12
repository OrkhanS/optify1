import 'package:flutter/material.dart';
import 'package:optifyapp/MembersUsers.dart';
import 'package:optifyapp/members.dart';
import 'package:optifyapp/screens/chat_window.dart';
import 'package:optifyapp/screens/chats_screen.dart';
import 'package:optifyapp/screens/profile_screen.dart';
import 'package:optifyapp/newActivityPersonal.dart';
import 'package:optifyapp/screens/auth_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optifyapp/screens/schedule_screen.dart';
import 'package:optifyapp/widgets/activityBox.dart';

void main(){
  
  Widget stabeTestmaker({Widget child}){
    return MaterialApp(
      home: child,
    );
  }
  testWidgets("Groups Screen Test", (WidgetTester tester) async{
    MembersUsers page = MembersUsers(); 
    await tester.pumpWidget(stabeTestmaker(child: page));

    var iconButton = find.byIcon(Icons.group);
    expect(iconButton, findsOneWidget);
    var text2 = find.text("My Groups");
    expect(text2, findsOneWidget);
  });
}