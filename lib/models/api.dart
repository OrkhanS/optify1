class Api {
  static const String address = "http://34.69.198.10/";
  static const roomSocket = "ws://34.69.198.10/chat/";
  static const aiSocket = "ws://34.69.198.10/ai/";
  static const createRoom = address + "api/chat/";
  static const chatRoomsList = address + "api/chats/";
  static const messageList = address + "api/chat/messages/?room_id=";
  static const userslistAndSignUp = address + "api/users/";
  static const login = address + "api/api-token-auth2/";
  static const myScheduleInfo = address + "api/schedules/my/";
  static const newActivityPersonal = address + "api/schedules/";
  static const myActivities = address + "api/schedules/";
  static const myContacts = address + "api/contacts/";
  static const removeContactRequst = address + "api/contacts/";
  static const respondContactRequst = address + "api/contacts/";
  static const createGroupAndMyGroups = address + "api/groups/";
}
