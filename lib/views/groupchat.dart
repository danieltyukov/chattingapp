import 'dart:async';
import 'package:aspireapp/helper/constants.dart';
import 'package:aspireapp/views/grouppage.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../groups/colors.dart';
import '../groups/messageItem.dart';
import '../groups/userModel.dart';
import '../groups/imageService.dart';


class GroupChat extends StatelessWidget {
  final String threadId;
  final String threadName;
  final UserModel userModel;
  GroupChat(
      {@required this.threadId, @required this.threadName, this.userModel});

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          title: Text(
            '$threadName',
            style: TextStyle(color: thirdColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ChatScreen(threadId: threadId, userModel: userModel),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String threadId;
  final UserModel userModel;
  ChatScreen({@required this.threadId, this.userModel});

  @override
  State createState() =>
      ChatScreenState(threadId: threadId, selectedUser: userModel);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({@required this.threadId, this.selectedUser});

  String threadId;
  UserModel selectedUser;
  String currentUserId;
  // String currentUserPhoto;
  String currentUserName;
  // bool _isRecording = false;
  // String _path;
  // StreamSubscription _recorderSubscription;
  // StreamSubscription _dbPeakSubscription;
  var listMessage;
  // SharedPreferences prefs;
  bool isLoading = false;
  String imageUrl = '';
  // String recordUrl = '';
  // String _recorderTxt = '00:00:00';
  String error;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  ImageServices imageServices;

  @override
  void initState() {
    // focusNode.addListener(onFocusChange);
    // user = await FirebaseAuth.instance.currentUser();
    doSomeAsyncStuff();

    readLocal();
    initializeDateFormatting();
    super.initState();
  }

  Future<void> doSomeAsyncStuff() async {
    await initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  readLocal() async {
    // prefs = await SharedPreferences.getInstance();
    await doSomeAsyncStuff();
    currentUserId = user.uid;
    print('please print $currentUserId');
    print(selectedUser);
    // currentUserPhoto = prefs.getString('image_url');
    currentUserName = Constants.myName;

    imageServices = ImageServices(
      threadId: threadId,
      selectedUser: selectedUser,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
    // currentUserPhoto: currentUserPhoto);
    setState(() {});
  }

  _onPickImages() async {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: 150,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Select The Image Source',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                      child: Text(
                        "Gallery",
                        style: TextStyle(fontSize: 15.0, color: textColor),
                      ),
                      onPressed: () async {
                        _selectMultibleImage(
                            await imageServices.getImages(cameraEnable: false));
                        Navigator.pop(context);
                      }),
                ),
                Expanded(
                  child: FlatButton(
                      child: Text(
                        "Back",
                        style: TextStyle(fontSize: 15.0, color: textColor),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          );
        });
  }

  _selectMultibleImage(List<Asset> assestimages) async {
    try {
      //1- open dialog to chose camera or select multi images
      Fluttertoast.showToast(msg: 'Upload image...');
      List _images = await imageServices.uploadIamges(assestimages);

      textEditingController.clear();
      onSendMessage(content: _images, type: 1);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Upload image faild');
    }
  }

  // Future<bool> onBackPress() {
  //   if (isShowSticker) {
  //     setState(() {
  //       isShowSticker = false;
  //     });
  //   } else {
  //     // // Firestore.instance
  //     // //     .collection('users')
  //     // //     .document(currentUserId)
  //     // //     .updateData({'chattingWith': null});
  //     // // Navigator.pop(context);
  //     // // Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  //     // Navigator.popUntil(context, (route) {
  //     //   return route.settings.isInitialRoute;
  //     // });
  //   }

  //   return Future.value(false);
  // }

  void onSendMessage({var content, int type}) {
    // type: 0 = text, 1 = image, 2 = sticker, 3 = record
    if (type != 1 && content.trim() == '') {
      Fluttertoast.showToast(msg: 'Nothing to send');
    } else {
      textEditingController.clear();
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(threadId)
          .collection(threadId)
          .document(timeStamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'threadId': threadId,
            'idFrom': currentUserId,
            'idTo': selectedUser != null ? selectedUser.id : '',
            'timestamp': timeStamp,
            'content': type == 1 ? '' : content,
            'images': type == 1 ? content : [],
            'type': type,
            'nameFrom': currentUserName,
            // 'photoFrom': currentUserPhoto,
            // 'recorderTime': type == 3 ? recorderTime : ''
          },
        );
      });

      Firestore.instance.collection('threads').document(threadId).updateData({
        'lastMessage': type == 0
            ? content
            : type == 1
                ? 'photo'
                : null
        //         type == 2
        //             ? 'sticker'
        //             : 'audio',
        // 'lastMessageTime': timeStamp
        //Firestore.instance.collection('messages').document(widget.threadId).collection(widget.threadId).document(timeStamp)
      });

      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),
            // Input content
            buildInput(),
          ],
        ),

        // Loading
        buildLoading()
      ],
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: widget.threadId == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  primaryColor,
                ),
              ),
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(widget.threadId)
                  .collection(widget.threadId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
                    itemBuilder: (context, index) => MessageItem(
                      index: index,
                      document: listMessage[index],
                      listMessage: listMessage,
                      currentUserId: currentUserId,
                    ),
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildInput() {
    return Container(
        width: double.infinity,
        height: 50.0,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: textColor, width: 0.5)),
            color: Color(0x54FFFFFF)),
        child: Stack(
          children: <Widget>[
            _buildNormalInput(),
          ],
        ));
  }

  Widget _buildNormalInput() {
    return Row(
      children: <Widget>[
        // Button send image

        Container(
          margin: EdgeInsets.symmetric(horizontal: 1.0),
          child: IconButton(
            icon: Icon(Icons.image),
            color: Colors.white,
            onPressed: _onPickImages,
          ),
        ),

        // Edit text
        Flexible(
          child: Container(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 15.0),
              controller: textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.white),
              ),
              focusNode: focusNode,
            ),
          ),
        ),
        // Button send message
        _buildMsgBtn(
          onPreesed: () =>
              onSendMessage(content: textEditingController.text, type: 0),
        )
      ],
    );
  }

  _buildMsgBtn({Function onPreesed}) {
    return Material(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: IconButton(
          icon: Icon(Icons.send),
          onPressed: onPreesed,
          color: Colors.white,
        ),
      ),
      color: Color(0x54FFFFF),
    );
  }
}
