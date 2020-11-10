import 'package:aspireapp/groups/userItem.dart';
import 'package:aspireapp/helper/constants.dart';
import 'package:aspireapp/views/groupchat.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import '../groups/loading_stack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../groups/colors.dart';
import '../groups/userModel.dart';

class GroupCreateScreen extends StatefulWidget {
  @override
  State createState() => GroupCreateScreenState();
}

class GroupCreateScreenState extends State<GroupCreateScreen> {
  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final TextEditingController textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  FirebaseUser currentUserId;
  List<UserModel> _selectedUsers = List();
  UserModel curentUserModel;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  readLocal() async {
    currentUserId = await _auth.currentUser();
  }

//
  void createGroup() async {
    _selectedUsers.add(curentUserModel);

    var threadId =
        currentUserId.uid + DateTime.now().millisecondsSinceEpoch.toString();

    // firebaseMessaging.subscribeToTopic(threadId);
    String groupName = textEditingController.text;
    Firestore.instance.collection('threads').document(threadId).setData({
      'name': groupName,
      'photoUrl': groupPhoto,
      'id': threadId,
      'users': _selectedUsers
          .map((item) => Firestore.instance
              .collection('users')
              .document('${item.userName}'))
          .toList(),
      'lastMessage': "",
      'creator': Constants.myName
    });

    _clearState();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChat(
          threadId: threadId,
          threadName: groupName,
        ),
      ),
    );
  }

//
//
  void _clearState() {
    _selectedUsers.clear();
    textEditingController.clear();
  }

  onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        closeFunction: () {},
        title: "Group Name",
        content: Form(
          key: _formKey,
          // ignore: deprecated_member_use
          autovalidate: true,
          child: TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              icon: Icon(Icons.group_work),
              labelText: 'group name',
            ),
            validator: (value) {
              if (textEditingController.text.trim() == '') {
                return 'Enter Group Name';
              } else if (textEditingController.text.length >= 20) {
                return 'Name Too Long';
              }
              return null;
            },
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context);
                createGroup();
              }
            },
            child: Text(
              "Create",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

//
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
          title: Text(
            'Create Group',
            style: TextStyle(color: thirdColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: LoadingStack(
          isLoading: isLoading,
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .orderBy('userName')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                );
                //
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(5.0),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    UserModel userZ =
                        UserModel.fromJson(snapshot.data.documents[index].data);
                    if (userZ.userName == Constants.myName) {
                      curentUserModel = userZ;
                      return SizedBox();
                    }
                    //
                    UserModel filteritem = _selectedUsers.firstWhere(
                        (item) => item.userName == userZ.userName,
                        orElse: () => null);

                    return CheckboxListTile(
                      value: filteritem != null,
                      title: UserItem(user: userZ, onPressed: null),
                      onChanged: (value) {
                        print(userZ.userName);
                        print(currentUserId.uid);
                        print(Constants.myName);
                        setState(
                          () {
                            if (value == true) {
                              _selectedUsers.add(userZ);
                            } else {
                              _selectedUsers.removeWhere(
                                  (item) => item.userName == userZ.userName);
                            }
                          },
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () => onAlertWithCustomContentPressed(context),
          backgroundColor: accentColor,
        ),
      ),
    );
  }
}
