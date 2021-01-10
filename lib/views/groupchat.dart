import 'dart:async';
import 'package:chattingapp/helper/constants.dart';
import 'package:chattingapp/helper/theme.dart';
import 'package:chattingapp/views/grouppage.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

            style: TextStyle(color: CustomTheme.thirdColor, fontWeight: FontWeight.bold),

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

  String currentUserName;

  var listMessage;
 
  bool isLoading = false;
  String imageUrl = '';

  String error;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;

  ImageServices imageServices;

  @override
  void initState() {
    doSomeAsyncStuff();

    readLocal();
    initializeDateFormatting();
    super.initState();
  }

  Future<void> doSomeAsyncStuff() async {
    await initUser();
  }

  initUser() async {
    user = _auth.currentUser;
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

    currentUserName = Constants.myName;

    imageServices = ImageServices(
      threadId: threadId,
      selectedUser: selectedUser,
      currentUserId: currentUserId,
      currentUserName: currentUserName,
    );
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
                        color: CustomTheme.primaryColor),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                      child: Text(
                        "Gallery",

                        style: TextStyle(fontSize: 15.0, color: CustomTheme.textColorOther),

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

                        style: TextStyle(fontSize: 15.0, color: CustomTheme.textColorOther),

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

  void onSendMessage({var content, int type}) {
    // type: 0 = text, 1 = image, 2 = sticker, 3 = record
    if (type != 1 && content.trim() == '') {
      Fluttertoast.showToast(msg: 'Nothing to send');
    } else {
      textEditingController.clear();
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(threadId)
          .collection(threadId)
          .doc(timeStamp);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
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
          },
        );
      });

      FirebaseFirestore.instance.collection('threads').doc(threadId).update(
        {
          'lastMessage': type == 0
              ? content
              : type == 1
                  ? 'photo'
                  : null,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
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
                    valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primaryColor)),
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
                  CustomTheme.primaryColor,
                ),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(widget.threadId)
                  .collection(widget.threadId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(CustomTheme.primaryColor)));
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
            border: Border(top: BorderSide(color: CustomTheme.textColorOther, width: 0.5)),
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
