import 'package:chattingapp/helper/constants.dart';
import 'package:chattingapp/services/database.dart';
import 'package:chattingapp/views/chat.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:chattingapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.docs[index].data()["userName"],
                searchResultSnapshot.docs[index].data()["userEmail"],
              );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName) {
    if (userName != Constants.myName) {
      List<String> users = [Constants.myName, userName];

      String chatRoomId = getChatRoomId(Constants.myName, userName);

      Map<String, dynamic> chatRoom = {
        "timer": DateTime.now().millisecondsSinceEpoch,
        "users": users,
        "chatRoomId": chatRoomId,
      };

      Map<String, int> currentUserCreate = {
        //while lastVisited is bigger no notification
        "lastMessage": 0,
        "lastVisited": DateTime.now().millisecondsSinceEpoch,
      };
      Map<String, int> otherUserCreate = {
        "lastMessage": 0,
        "lastVisited": DateTime.now().millisecondsSinceEpoch,
      };

      databaseMethods.addChatRoom(chatRoom, chatRoomId);
      databaseMethods.addCurrentUser(
          chatRoomId, Constants.myName, currentUserCreate);
      databaseMethods.addOthertUser(chatRoomId, userName, otherUserCreate);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            chatRoomId: chatRoomId,
          ),
        ),
      );
    } else {
      print('why are you searching yourself');
    }
  }

  Widget userTile(String userName, String userEmail) {
    if (userName != Constants.myName) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                sendMessage(userName);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                    color: Color(0xff036240),
                    borderRadius: BorderRadius.circular(24)),
                child: Text(
                  "Message",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
      connectivityBuilder: (BuildContext context,
          ConnectivityResult connectivity, Widget child) {
        final bool connected = connectivity != ConnectivityResult.none;
        if (!connected) {
          return offlinescreen(context);
        } else {
          return child;
        }
      },
      child: Scaffold(
        appBar: appBarMain(context),
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      color: Color(0x54FFFFFF),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchEditingController,
                              style: simpleTextStyle(),
                              decoration: InputDecoration(
                                  hintText: "Search By Full Name",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              initiateSearch();
                            },
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color(0x36FFFFFF),
                                          const Color(0x0FFFFFFF)
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight),
                                    borderRadius: BorderRadius.circular(40)),
                                padding: EdgeInsets.all(12),
                                child: Image.asset(
                                  "assets/images/search_white.png",
                                  height: 25,
                                  width: 25,
                                )),
                          )
                        ],
                      ),
                    ),
                    userList()
                  ],
                ),
              ),
      ),
    );
  }
}
