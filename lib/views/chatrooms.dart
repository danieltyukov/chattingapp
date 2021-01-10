import 'package:chattingapp/helper/authenticate.dart';
import 'package:chattingapp/helper/constants.dart';
import 'package:chattingapp/helper/getimagesusers.dart';
import 'package:chattingapp/helper/helperfunctions.dart';
import 'package:chattingapp/services/auth.dart';
import 'package:chattingapp/services/database.dart';
import 'package:chattingapp/views/chat.dart';
import 'package:chattingapp/views/search.dart';
import 'package:chattingapp/widget/drawer.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;

  ChatRoom({this.chatRoomId});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.documents[index]
                        .data()['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myName, ""),
                    myuserName: Constants.myName,
                    chatRoomId:
                        snapshot.data.documents[index].data()["chatRoomId"],
                    snapshot: snapshot,
                    index: index,
                  );
                },
              )
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfogetChats();

    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
        print(widget.chatRoomId);
      });
    });
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
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chat',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'Chat',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.lightBlue,
                ),
              )
            ],
          ),
          elevation: 0.0,
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Sign Out?'),
                      content: Text('Do You Wish To Sign Out?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text('Yes'),
                          onPressed: () {
                            HelperFunctions.saveUserLoggedInSharedPreference(
                                false);
                            AuthService().signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Authenticate()));
                          },
                        )
                      ],
                    );
                  },
                );
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.exit_to_app)),
            )
          ],
        ),
        drawer: drawer(context),
        body: Container(
          child: chatRoomsList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Search()));
          },
        ),
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String myuserName;
  final String chatRoomId;
  final AsyncSnapshot<dynamic> snapshot;
  final int index;
  final Stream timing;

  ChatRoomsTile({
    @required this.userName,
    @required this.myuserName,
    @required this.chatRoomId,
    @required this.snapshot,
    @required this.index,
    this.timing,
  });

  @override
  Widget build(BuildContext context) {
    // DatabaseMethods().getTimer(chatRoomId, myuserName);

    return GestureDetector(
      onTap: () {
        DatabaseMethods().visitedTime(chatRoomId, Constants.myName,
            DateTime.now().millisecondsSinceEpoch);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              chatRoomId: chatRoomId,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xff476cfb),
                child: ClipOval(
                  child: SizedBox(
                      width: 40, height: 40, child: GetImagesUsers(userName)),
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              userName,
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'OverpassRegular',
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(
              width: 12,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatRoom')
                  .doc(chatRoomId)
                  .collection(Constants.myName)
                  .doc(Constants.myName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userTimer = snapshot.data;
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: userTimer["lastMessage"] != null
                          ? userTimer["lastMessage"] > userTimer["lastVisited"]
                              ? Colors.blue
                              : Colors.grey
                          : Colors.grey,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Chat Room?'),
                        content: Text('Do You Wish To Delete The Chat Room?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.pop(context);
                              print(timing.toString());
                            },
                          ),
                          FlatButton(
                            child: Text('Yes'),
                            onPressed: () {
                              FirebaseFirestore.instance.runTransaction(
                                  (Transaction myTransaction) async {
                                myTransaction.delete(
                                    snapshot.data.documents[index].reference);
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
              },
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
