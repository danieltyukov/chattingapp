import 'package:aspireapp/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/profile.dart';

class DatabaseMethods {
  static var specialValue;
  Future<void> addUserInfo(userData, userSpecialId) async {
    Firestore.instance
        .collection("users")
        .document(userSpecialId)
        .setData(userData)
        .then((value) => specialValue = userSpecialId)
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
        .orderBy('time')
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

  Future<void> addImage(String url) async {
    await Firestore.instance
        .collection('users')
        .document(DatabaseMethods.specialValue)
        .updateData(<String, String>{'image_url': url});
  }

  // getImage(String user) async {
  //   await Firestore.instance
  //       .collection('users')
  //       .where('image_url', isEqualTo: user)
  //       .getDocuments();
  // }

  getUserChats(String itIsMyName) async {
    return await Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }

  Future<bool> usernameCheck(String username) async {
    final result = await Firestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .getDocuments();
    return result.documents.isEmpty;
  }
}
