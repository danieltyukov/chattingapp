import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData, user) async {
    Firestore.instance
        .collection("users")
        .document(user)
        .setData(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addCurrentUser(
      String chatRoomId, String userName, currentUserCreate) async {
    await Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection(userName)
        .document(userName)
        .setData(currentUserCreate)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addOthertUser(
      String chatRoomId, String userName, otherUserCreate) async {
    await Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection(userName)
        .document(userName)
        .setData(otherUserCreate)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> messageTime(
      String chatRoomId, String userName, int lastMessage) async {
    print(lastMessage);
    await Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection(userName)
        .document(userName)
        .setData(
      <String, dynamic>{'lastMessage': lastMessage},
      merge: true,
    );
  }

  Future<void> visitedTime(
      String chatRoomId, String userName, int lastVisited) async {
    print(lastVisited);
    await Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection(userName)
        .document(userName)
        .setData(
      <String, dynamic>{'lastVisited': lastVisited},
      merge: true,
    );
  }

  Future<void> addImage(String url, dynamic user) async {
    print(user);
    await Firestore.instance.collection('users').document(user).setData(
      <String, String>{'image_url': url},
      merge: true,
    );
  }

  Future<void> groupImageChange(String url, dynamic threadId) async {
    await Firestore.instance.collection('threads').document(threadId).setData(
      <String, String>{'photoUrl': url},
      merge: true,
    );
  }

  Future<void> publishImage(String chatRoomId, chatMessageData) async {
    print(chatRoomId);
    await Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection('chats')
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String itIsMyName) async {
    return Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .orderBy('timer', descending: true)
        .snapshots();
  }

  sortChats(dynamic timestamp, String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(
      <String, dynamic>{'timer': timestamp},
      merge: true,
    );
  }

  Future<bool> usernameCheck(String username) async {
    final result = await Firestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .getDocuments();
    return result.documents.isEmpty;
  }
}
