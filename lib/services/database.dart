import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData, user) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user)
        .set(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addCurrentUser(
      String chatRoomId, String userName, currentUserCreate) async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection(userName)
        .doc(userName)
        .set(currentUserCreate)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addOthertUser(
      String chatRoomId, String userName, otherUserCreate) async {
    await FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection(userName)
        .doc(userName)
        .set(otherUserCreate)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> messageTime(
      String chatRoomId, String userName, int lastMessage) async {
    print(lastMessage);
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection(userName)
        .doc(userName)
        .set(
      <String, dynamic>{'lastMessage': lastMessage},
      
      SetOptions(merge : true)
    );
  }

  Future<void> visitedTime(
      String chatRoomId, String userName, int lastVisited) async {
    print(lastVisited);
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection(userName)
        .doc(userName)
        .set(
      <String, dynamic>{'lastVisited': lastVisited},
      SetOptions(merge : true)
    );
  }

  Future<void> addImage(String url, dynamic user) async {
    print(user);
    await FirebaseFirestore.instance.collection('users').doc(user).set(
      <String, String>{'image_url': url},
      SetOptions(merge : true)
    );
  }

  Future<void> groupImageChange(String url, dynamic threadId) async {
    await FirebaseFirestore.instance.collection('threads').doc(threadId).set(
      <String, String>{'photoUrl': url},
      SetOptions(merge : true)
    );
  }

  Future<void> publishImage(String chatRoomId, chatMessageData) async {
    print(chatRoomId);
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserChats(String itIsMyName) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .orderBy('timer', descending: true)
        .snapshots();
  }

  sortChats(dynamic timestamp, String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(
      <String, dynamic>{'timer': timestamp},
      SetOptions(merge : true)
    );
  }

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }
}
