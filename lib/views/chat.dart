import 'dart:async';
import 'dart:io';

import 'package:chattingapp/helper/constants.dart';
import 'package:chattingapp/helper/theme.dart';
import 'package:chattingapp/services/database.dart';
import 'package:chattingapp/views/chatrooms.dart';
import 'package:chattingapp/views/fullimage.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:chattingapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();

  User user;
  File _image;
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  initUser() async {
    user = _auth.currentUser;

    setState(() {});
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                controller: _scrollController,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data()["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data()["sendBy"],
                    sendBy: snapshot.data.documents[index].data()["sendBy"],
                    snapshot: snapshot,
                    index: index,
                    imageCheck: snapshot.data.documents[index].data()["image"],
                  );
                },
              )
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        "time": timestamp,
        "image": 'no',
      };
      print(timestamp);

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
      String otherChatRoomIdName = widget.chatRoomId
          .toString()
          .replaceAll("_", "")
          .replaceAll(Constants.myName, "");
      print(otherChatRoomIdName);

      databaseMethods.messageTime(
          widget.chatRoomId, otherChatRoomIdName, timestamp);

      databaseMethods.sortChats(timestamp, widget.chatRoomId);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    initUser();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      Timer(
        Duration(milliseconds: 100),
        () => _scrollController
            .jumpTo(_scrollController.position.minScrollExtent),
      );
      setState(() {
        chats = val;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future getImage() async {
      // ignore: deprecated_member_use
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
        print('Image Path $_image');
      });
    }

    Future uploadPic(BuildContext context) async {
      // String fileName = basename(_image.path);
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('upload_image')
          .child(
              user.uid + '${DateTime.now().millisecondsSinceEpoch}' + '.jpg');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image);
      //MIGHT CAUSE ERROR
      TaskSnapshot taskSnapshot = await uploadTask;
      final url = await taskSnapshot.ref.getDownloadURL();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": url,
        "time": timestamp,
        "image": 'yes',
      };
      print(timestamp);
      databaseMethods.publishImage(widget.chatRoomId, chatMessageMap);

      String otherChatRoomIdName = widget.chatRoomId
          .toString()
          .replaceAll("_", "")
          .replaceAll(Constants.myName, "");

      databaseMethods.messageTime(
          widget.chatRoomId, otherChatRoomIdName, timestamp);

      databaseMethods.sortChats(timestamp, widget.chatRoomId);
    }

    return SafeArea(
      child: OfflineBuilder(
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
            centerTitle: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                DatabaseMethods().visitedTime(widget.chatRoomId,
                    Constants.myName, DateTime.now().millisecondsSinceEpoch);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(
                      chatRoomId: widget.chatRoomId,
                    ),
                  ),
                );
              },
            ),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: chatMessages(),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    color: Color(0x54FFFFFF),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            // margin: EdgeInsets.symmetric(horizontal: 1.0),
                            child: IconButton(
                              // padding: EdgeInsets.all(0),
                              icon: Icon(Icons.image),
                              color: Colors.white,

                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (builder) {
                                      return Container(
                                        height: 150,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.0),
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
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: CustomTheme.textColorOther),
                                                  ),
                                                  onPressed: () async {
                                                    await getImage()
                                                        .then((value) =>
                                                            uploadPic(context))
                                                        .then((value) =>
                                                            chatMessages());
                                                  }),
                                            ),
                                            Expanded(
                                              child: FlatButton(
                                                  child: Text(
                                                    "Back",
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: CustomTheme.textColorOther),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  }),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        Expanded(
                            child: Container(
                          child: GestureDetector(
                            onTap: () {
                              Timer(
                                Duration(milliseconds: 100),
                                () => _scrollController.jumpTo(
                                    _scrollController.position.minScrollExtent),
                              );
                            },
                            child: TextField(
                              controller: messageEditingController,
                              style: simpleTextStyle(),
                              decoration: InputDecoration(
                                  hintText: "Type your message...",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                        )),
                        // SizedBox(
                        //   width: 16,
                        // ),
                        GestureDetector(
                          onTap: () {
                            Timer(
                              Duration(milliseconds: 100),
                              () => _scrollController.jumpTo(
                                  _scrollController.position.minScrollExtent),
                            );
                            addMessage();
                          },
                          child: Container(
                            // height: 40,
                            // width: 40,
                            // decoration: BoxDecoration(
                            //     gradient: LinearGradient(
                            //         colors: [
                            //           const Color(0x36FFFFFF),
                            //           const Color(0x0FFFFFFF)
                            //         ],
                            //         begin: FractionalOffset.topLeft,
                            //         end: FractionalOffset.bottomRight),
                            //     borderRadius: BorderRadius.circular(40)),
                            // padding: EdgeInsets.all(12),
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            // child: Image.asset(
                            //   "assets/images/send.png",
                            //   height: 25,
                            //   width: 25,
                            // ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final dynamic message;
  final bool sendByMe;
  final String sendBy;
  final AsyncSnapshot<dynamic> snapshot;
  final int index;
  final String imageCheck;

  MessageTile({
    @required this.message,
    @required this.sendByMe,
    @required this.sendBy,
    @required this.snapshot,
    @required this.index,
    @required this.imageCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              top: 1,
              bottom: 1,
              left: sendByMe ? 0 : 17,
              right: sendByMe ? 17 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: sendByMe
              ? null
              : Text(
                  '$sendBy',
                  style: TextStyle(
                      color: CustomTheme.textColorOther,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
        ),
        GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                if (sendByMe) {
                  if (imageCheck == 'no') {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlatButton(
                            child: Text('Unsend Message'),
                            onPressed: () {
                              FirebaseFirestore.instance.runTransaction(
                                  (Transaction myTransaction) async {
                                myTransaction.delete(
                                    snapshot.data.documents[index].reference);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Copy Text'),
                            onPressed: () {
                              Clipboard.setData(
                                new ClipboardData(text: message),
                              );
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlatButton(
                            child: Text('Unsend Message'),
                            onPressed: () {
                              FirebaseFirestore.instance.runTransaction(
                                  (Transaction myTransaction) async {
                                myTransaction.delete(
                                    snapshot.data.documents[index].reference);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Save Image'),
                            onPressed: () async {
                              try {
                                // Saved with this method.
                                var imageId =
                                    await ImageDownloader.downloadImage(
                                        message);
                                if (imageId == null) {
                                  return;
                                }
                                //FOR FUTURE REFERENCE
                                // // Below is a method of obtaining saved image information.
                                // var fileName =
                                //     await ImageDownloader.findName(imageId);
                                // var path =
                                //     await ImageDownloader.findPath(imageId);
                                // var size =
                                //     await ImageDownloader.findByteSize(imageId);
                                // var mimeType =
                                //     await ImageDownloader.findMimeType(imageId);

                              } on PlatformException catch (error) {
                                print(error);
                              }
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  }
                } else {
                  // SizedBox.shrink();
                  if (imageCheck == 'no') {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlatButton(
                            child: Text('Copy Text'),
                            onPressed: () {
                              Clipboard.setData(
                                new ClipboardData(text: message),
                              );
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  } else {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlatButton(
                            child: Text('Save Image'),
                            onPressed: () async {
                              try {
                                // Saved with this method.
                                var imageId =
                                    await ImageDownloader.downloadImage(
                                        message);
                                if (imageId == null) {
                                  return;
                                }
                                //FOR FUTURE REFERENCE
                                // // Below is a method of obtaining saved image information.
                                // var fileName =
                                //     await ImageDownloader.findName(imageId);
                                // var path =
                                //     await ImageDownloader.findPath(imageId);
                                // var size =
                                //     await ImageDownloader.findByteSize(imageId);
                                // var mimeType =
                                //     await ImageDownloader.findMimeType(imageId);

                              } on PlatformException catch (error) {
                                print(error);
                              }
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  }
                }
              },
            );
          },
          child: imageCheck == 'no'
              ? Container(
                  padding: EdgeInsets.only(
                      top: 1,
                      bottom: 12,
                      left: sendByMe ? 0 : 12,
                      right: sendByMe ? 12 : 0),
                  alignment:
                      sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: message.length > 40
                        ? MediaQuery.of(context).size.width * 0.7
                        : null,
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        gradient: LinearGradient(
                          colors: sendByMe
                              ? [CustomTheme.textColorOther, CustomTheme.textColorOther]
                              : [CustomTheme.primaryColor, CustomTheme.primaryColor],
                        )),
                    child: Linkify(
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                        text: message,
                        textAlign: TextAlign.start,
                        linkStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        style: TextStyle(
                            color: Colors.white,
                            // fontSize: 12,
                            fontFamily: 'OverpassRegular',
                            fontWeight: FontWeight.w400)),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullImage(message),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 1,
                        bottom: 12,
                        left: sendByMe ? 0 : 12,
                        right: sendByMe ? 12 : 0),
                    alignment:
                        sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white),
                      child: Image.network(message, fit: BoxFit.fill,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
