import 'package:flutter/material.dart';
import 'package:optifyapp/models/api.dart';
import 'package:optifyapp/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Messages extends ChangeNotifier {
  Map _messages = {};
  List _chatRooms = [];
  Map tmp = {};
  Map newMessage = {};
  int newMessageCount;
  int tmpIDofMessage = 0;
  String tokenforROOM;
  bool isUserlogged = true;
  bool isChatsLoading = true;
  bool _isloadingMessages = true;
  bool ismessagesAdded = false;
  List lastMessageID = [];
  Map userdetail = {};
  Map allChatRoomDetails = {};

  String get getToken {
    return tokenforROOM;
  }

  Future fetchAndSetMessages(int i) async {
    // var token = tokenforROOM;
    // String url = "https://briddgy.herokuapp.com/api/chat/messages/?room_id=" + _chatRooms[i]["id"].toString();
    // try {
    //   await http.get(
    //     url,
    //     headers: {
    //       HttpHeaders.CONTENT_TYPE: "application/json",
    //       "Authorization": "Token " + token,
    //     },
    //   ).then((response) {
    //     var dataOrders = json.decode(response.body) as Map<String, dynamic>;
    //     _messages[_chatRooms[i]["id"]] = dataOrders;
    //     _isloadingMessages = false;
    //     notifyListeners();
    //   });
    // } catch (e) {}
  }

  bool get messagesNotLoaded {
    return _isloadingMessages;
  }

  Map get newMessages {
    return newMessage;
  }

  set addMessages(Map mesaj) {
    ismessagesAdded = false;
    var room = mesaj["data"] == null ? mesaj["room_id"] : mesaj["data"]["room_id"];
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[room] != null) {
        if (_messages[room]["results"][0]["id"] != mesaj["id"]) {
          lastMessageID.add(mesaj["data"] == null ? mesaj["id"] : mesaj["data"]["id"]);
          _messages[room]["results"].insert(0, mesaj);
          changeChatRoomPlace(room);
        }
        ismessagesAdded = true;
      }
    }
    if (ismessagesAdded == false) {
      ismessagesAdded = true;
      bool okay = changeChatRoomPlace(room);
      if (!okay) {
        _chatRooms.insert(0, mesaj);
      }
      lastMessageID.add(mesaj["data"] == null ? mesaj["id"] : mesaj["data"]["id"]);
    }
    if (ismessagesAdded == true) {
      var lastindex = lastMessageID.lastIndexOf(lastMessageID.last);
      var flag = false;
      bool testforLastMessage;
      try {
        testforLastMessage = lastMessageID.last != lastMessageID[lastindex - 1];
      } catch (e) {
        flag = true;
      }
      if (testforLastMessage == true || flag == true) {
        testforLastMessage = false;
        if (newMessage[room] == null) {
          newMessageCount = 1;
          newMessage[room] = newMessageCount;
        } else {
          newMessage[room] = newMessage[room] + 1;
        }
      } else {
        lastMessageID = [];
      }
    }
    notifyListeners();
  }

  Map allAddMessages(Map mesaj) {
    _messages[mesaj["room_id"]] = mesaj;
    notifyListeners();
    return _messages;
  }

  Map get messages => _messages;

  void readMessages(id) {
    readLastMessages(id);
    newMessage[id] = 0;
    //newMessage.remove(id);
  }

  bool get arethereNewMessage {
    var key = newMessage.keys.firstWhere((k) => newMessage[k] != 0, orElse: () => null);
    if (key != null) {
      return true;
    } else {
      return false;
    }
  }

  Future readLastMessages(id) async {
    var token = tokenforROOM;
    try {
      const url = "http://briddgy.herokuapp.com/api/chat/readlast/";

      http.post(url,
          headers: {
            HttpHeaders.CONTENT_TYPE: "application/json",
            "Authorization": "Token " + token,
          },
          body: json.encode({
            "room_id": id,
          }));
    } catch (error) {
      throw error;
    }
  }

  //______________________________________________________________________________________


  Future createRooms(id, auth) async {
    String tokenforROOM = auth.myToken;
    if (tokenforROOM != null) {
      String url = Api.createRoom + id.toString()+"/";
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.CONTENT_TYPE: "application/json",
          "Authorization": "Token " + tokenforROOM,
        },
      ).then((onValue){
        print(json.decode(onValue.body));
      });
      fetchAndSetRooms(auth);
    }
    return null;
  }

  bool changeChatRoomPlace(id) {
    newMessage[id] = 0;
    for (var i = 0; i < _chatRooms.length; i++) {
      if (_chatRooms[i]["id"] == id) {
        _chatRooms.insert(0, _chatRooms.removeAt(i));
        newMessage[id] = 0;
        return true;
      }
    }
    newMessage[id] = 0;
    return false;
  }

  Future fetchAndSetRooms(auth) async {
    var f;
    auth.removeListener(f);
    try {
      if (auth.myToken != null) {
        const url = Api.chatRoomsList;
        final response = await http.get(
          url,
          headers: {
            HttpHeaders.CONTENT_TYPE: "application/json",
            "Authorization": "Token " + auth.myToken,
          },
        ).then((value) {
          final dataOrders = json.decode(value.body) as Map<String, dynamic>;
          allChatRoomDetails = dataOrders;
          _chatRooms = dataOrders["results"];
          isChatsLoading = false;
        });
        return _chatRooms;
      } else {
        isUserlogged = true;
        return null;
      }
    } catch (e) {
      return;
    }
  }

  set addChats(Map mesaj) {
    //here goes new room
    notifyListeners();
  }

  List allAddChats(List rooms) {
    _chatRooms = rooms;
    //notifyListeners();
    return _chatRooms;
  }

  bool get userNotLogged {
    return isUserlogged;
  }

  bool get chatsNotLoaded {
    return isChatsLoading;
  }

  List get chats => _chatRooms;
  Map get chatDetails => allChatRoomDetails;
  Map user_detail = {};
  Map get userDetails {
    return user_detail;
  }

  Future fetchAndSetUserDetails(auth) async {
    // var f;
    // auth.removeListener(f);
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('userData')) {
    //   return false;
    // }
    // final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    // auth.token = extractedUserData['token'];
    // var token = extractedUserData['token'];
    // try {
    //   const url = "http://briddgy.herokuapp.com/api/users/me/";

    //   final response = await http.get(
    //     url,
    //     headers: {
    //       HttpHeaders.CONTENT_TYPE: "application/json",
    //       "Authorization": "Token " + token,
    //     },
    //   ).then((response) {
    //     var dataOrders = json.decode(response.body) as Map<String, dynamic>;
    //     user_detail = dataOrders;
    //   });
    // } catch (error) {}
  }
}
