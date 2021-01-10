import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/helper/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fullPhoto.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    @required this.index,
    @required this.document,
    @required this.listMessage,
    @required this.currentUserId,
  });

  final String currentUserId;
  final document;
  final int index;
  final List listMessage;

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  double maxDuration = 1.0;
  String playerTxt = '00:00:00';
  double sliderCurrentPosition = 0.0;

  // StreamSubscription _playerSubscription;

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            widget.listMessage != null &&
            widget.listMessage[index - 1]['idFrom'] !=
                widget.listMessage[index]['idFrom']) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool _islastIndex(int index) {
    if (index > 0 &&
        (widget.listMessage[index - 1]['idFrom'] !=
            widget.listMessage[index]['idFrom'])) {
      return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _islastIndex(widget.index) ? 25.0 : 15.0),
      child: _buildItem(),
    );
  }

  _buildItem() {
    if (widget.document['idFrom'] == widget.currentUserId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          widget.document['type'] == 0
              ? _textWidget(color: CustomTheme.textColorOther)
              : widget.document['type'] == 1
                  // Image
                  ? _imagesWidget()
                  // Sticker
                  : null

          // widget.document['type'] == 3
          //     ? _voiceContainer(widget.document['content'], widget.document['recorderTime'])
          //     : _stickerWidget(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Column(
        children: <Widget>[
          isLastMessageLeft(widget.index)
              ? Container(
                  margin: EdgeInsets.only(left: 5.0, bottom: 4.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${widget.document['nameFrom']}',
                        style: TextStyle(
                            color: CustomTheme.textColorOther,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            int.parse(
                              widget.document['timestamp'],
                            ),
                          ),
                        ),
                        style: TextStyle(
                            color: CustomTheme.textColorOther,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ))
              : Container(),
          Row(
            children: <Widget>[
              // isLastMessageLeft(widget.index)
              // ? _userPhoto()
              // :
              // Container(width: 43.0), // 35 width of photo + 8 of margin

              //  show text or image
              _showFriendContent(),
            ],
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  _textWidget({Color color}) {
    return Flexible(
      child: Container(
        width: widget.document['content'].length > 40
            ? MediaQuery.of(context).size.width * 0.7
            : null,
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        // margin: edg,
        child: Linkify(
          onOpen: (link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw 'Could not launch $link';
            }
          },
          text: '${widget.document['content']}',
          linkStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          style: TextStyle(color: Colors.white),
        ),
        decoration: BoxDecoration(
            color: color ?? CustomTheme.primaryColor,
            borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  _imagesWidget() {
    double _containerSize = 200.0;
    List images = widget.document['images'];
    double _imgSize = _containerSize * 0.9;

    return Container(
      // color: Colors.grey.shade300,
      width: 200,
      height: 200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length == 1 ? 1 : 2,
        ),
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildImgItem(index: index, images: images, size: _imgSize);
        },
      ),
    );
  }

  _buildImgItem({double size, List images, int index}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullPhoto(images: images, index: index)));
      },
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              if (widget.document['idFrom'] == widget.currentUserId) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlatButton(
                        child: Text('Unsend Message'),
                        onPressed: () async {
                          FirebaseFirestore.instance.runTransaction(
                              (Transaction myTransaction) async {
                            myTransaction.delete(widget.document['images']);
                          });
                          Navigator.pop(context);

                          try {
                            // Saved with this method.
                            var imageId = await ImageDownloader.downloadImage(
                                images[index]);
                            if (imageId == null) {
                              return;
                            }
                          } on PlatformException catch (error) {
                            print(error);
                          }
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('Save Image'),
                        onPressed: () async {
                          try {
                            // Saved with this method.
                            var imageId = await ImageDownloader.downloadImage(
                                images[index]);
                            if (imageId == null) {
                              return;
                            }
                          } on PlatformException catch (error) {
                            print(error);
                          }
                          Navigator.pop(context);
                        },
                      ),
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
                            var imageId = await ImageDownloader.downloadImage(
                                images[index]);
                            if (imageId == null) {
                              return;
                            }
                          } on PlatformException catch (error) {
                            print(error);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
        child: Container(
          // height: size,
          // width: size,
          padding: EdgeInsets.all(5.0),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            // border: Border.all(color: Colors.grey.shade300, width: 3),
          ),
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.fill,
            placeholder: (_, _url) => Container(
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primaryColor),
              )),
            ),
            errorWidget: (_, url, error) => Container(
              child: Image.asset(
                'assets/images/img_not_available.jpeg',
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showFriendContent() {
    // id to
    if (widget.document['type'] == 0) {
      // txt
      return _textWidget(color: CustomTheme.primaryColor);
    } else if (widget.document['type'] == 1) {
      //img
      return _imagesWidget();
    }
    return Container();
  }
}
