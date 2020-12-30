import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:aspireapp/helper/constants.dart';
import 'package:aspireapp/services/database.dart';
import 'package:aspireapp/views/snake.dart';
import 'package:aspireapp/widget/drawer.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';

import '../groups/colors.dart';
import '../groups/loading_stack.dart';
import '../groups/userModel.dart';
import '../groups/thread.dart';
import '../groups/imageAvatar.dart';
import 'groupchat.dart';
import 'creategroups.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/home';
  @override
  State createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  dynamic snapshot;
  // List threads = [];
  bool isLoading = false;
  // String currentUserId;
  // var _isInit = true;

  @override
  void initState() {
    initUser();

    super.initState();
  }

  initUser() async {
    user = await _auth.currentUser;

    setState(() {});
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
            children: [
              Text(
                'Aspire',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'Groups',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.lightBlue,
                ),
              )
            ],
          ),
        ),
        drawer: drawer(context),
        body: LoadingStack(
          isLoading: isLoading,
          child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('threads')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                snapshot = snapshot;
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                } else {
                  // get my threads
                  List threads = (snapshot.data.documents as List).where((t) {
                    return t.data()['users']
                        .any((u) => u.documentID == Constants.myName);
                  }).toList();

                  print(threads);

                  return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        return ThreadItem(
                          key: UniqueKey(),
                          thread: threads[index],
                          currentUserId: user.uid,
                          index: index,
                          snapshot: snapshot,
                        );
                      });
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.group_add),
          onPressed: () {
            print('${user.uid}');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => GroupCreateScreen()));
          },
        ),
      ),
    );
  }
}

class ThreadItem extends StatefulWidget {
  final dynamic thread;
  final String currentUserId;
  final dynamic snapshot;
  final dynamic index;

  ThreadItem({
    this.thread,
    this.currentUserId,
    Key key,
    this.index,
    this.snapshot,
  }) : super(key: key);

  @override
  _ThreadItemState createState() => _ThreadItemState();
}

class _ThreadItemState extends State<ThreadItem> with AfterLayoutMixin {
  ThreadModel threadData;
  UserModel userModel;
  File _imageGroup;
  DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        threadData = ThreadModel.fromJson(widget.thread.data());
      });
    }
    // get name and photo of second user
    if ((widget.thread.data()["users"] as List).length == 2) {
      DocumentReference userRef = (widget.thread.data()["users"] as List)
          .firstWhere((u) => u.documentID != widget.currentUserId);
      userRef.get().then((snap) {
        if (mounted) {
          setState(() {
            threadData.name = snap.data()['name'];
            threadData.photoUrl = snap.data()['photoUrl'];
            userModel = UserModel.fromJson(snap.data());
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future uploadGroupPic(BuildContext context) async {
      // String fileName = basename(_image.path);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(_imageGroup.toString());
      UploadTask uploadTask = firebaseStorageRef.putFile(_imageGroup);
      //MIGHT CAUSE AN ERROR
      TaskSnapshot taskSnapshot = await uploadTask;
      final url = await taskSnapshot.ref.getDownloadURL();
      databaseMethods.groupImageChange(url, widget.thread.documentID);

      setState(() {
        print("Group Page Image Changed");
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Group Page Image Changed'),
          ),
        );
      });
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      child: FlatButton(
        onPressed: _onPressed,
        child: Row(
          children: <Widget>[
            threadData != null
                ? GestureDetector(
                    onLongPress: () async {
                      // ignore: deprecated_member_use
                      var image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);

                      setState(() {
                        _imageGroup = image;
                        print('Image Path $_imageGroup');

                        print(widget.thread.documentID);
                      });
                      uploadGroupPic(context);
                    },
                    child: ImageAvatar(imgUrl: threadData.photoUrl))
                : SizedBox(),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        threadData != null ? threadData.name : "",
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    Container(
                      child: Text(
                        (() {
                          if (threadData != null) {
                            if (threadData.lastMessage.length > 10) {
                              return threadData.lastMessage.substring(0, 10);
                            } else {
                              return threadData.lastMessage;
                            }
                          } else {
                            return "";
                          }
                        }()),
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    )
                  ],
                ),
              ),
            ),
            (() {
              if (Constants.myName == widget.thread.data()["creator"]) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Group Chat?'),
                            content:
                                Text('Do You Wish To Delete The Group Chat?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.runTransaction(
                                      (Transaction myTransaction) async {
                                     myTransaction.delete(widget
                                        .snapshot
                                        .data
                                        .documents[widget.index]
                                        .reference);
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
                      color: Colors.black,
                    ),
                  ),
                );
              } else {
                return Container();
                //Here issue with reference being non retrievable.
                //------------------------
                // return GestureDetector(
                //   onTap: () {
                //     showDialog(
                //         context: context,
                //         barrierDismissible: true,
                //         // ignore: missing_return
                //         builder: (BuildContext context) {
                //           return AlertDialog(
                //             title: Text('Leave The Group?'),
                //             content: Text('Do You Wish To Leave The Group?'),
                //             actions: <Widget>[
                //               FlatButton(
                //                 child: Text('No'),
                //                 onPressed: () {
                //                   Navigator.pop(context);
                //                 },
                //               ),
                //               FlatButton(
                //                 child: Text('Yes'),
                //                 onPressed: () async {
                //                   print(threadData.id);
                //                   print(widget.currentUserId);
                //                   print(Firestore.instance
                //                       .collection('users')
                //                       .document('${widget.currentUserId}').documentID);
                //                   // DocumentReference docRef = Firestore.instance
                //                   //     .collection('threads')
                //                   //     .document(widget.snapshot.data.documents);
                //                   // print('${widget.thread}');
                //                   // DocumentSnapshot doc = await docRef.get();
                //                   // List userTags = doc.data['users'];
                //                   // print("$userTags");
                //                   await Firestore.instance
                //                       .collection("threads")
                //                       .document(threadData.id)
                //                       .updateData({
                //                     'users': FieldValue.arrayRemove([
                //                       Firestore.instance
                //                           .collection('users')
                //                           .document('${widget.currentUserId}')
                //                           .path
                //                     ])
                //                   });
                //                   Navigator.pop(context);

                //                   // await widget.thread.reference.updateData({
                //                   //   'users': FieldValue.arrayRemove(
                //                   //       ["/users/${Constants.myName}"])
                //                   // });
                //                   // // (item) => item.id == {Constants.myName});
                //                 },
                //               )
                //             ],
                //           );
                //         });
                //   },
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: Icon(
                //       Icons.exit_to_app,
                //       color: Colors.black,
                //     ),
                //   ),
                // );
              }
            }())
          ],
        ),
        color: thirdColor,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  void _onPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChat(
            threadId: threadData.id,
            threadName: threadData.name,
            userModel: userModel),
      ),
    );
  }
}
