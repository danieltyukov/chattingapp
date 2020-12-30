import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'fullPhoto.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'colors.dart';

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

  // void startPlayer(String recordUrl) async {
  //   try {
  //     String path =
  //         await widget.flutterSound.startPlayer(recordUrl); // From file

  //     if (path == null) {
  //       print('Error starting player');
  //       return;
  //     }
  //     print('startPlayer: $path');
  //     await widget.flutterSound.setVolume(1.0);

  //     _playerSubscription =
  //         widget.flutterSound.onPlayerStateChanged.listen((e) {
  //       if (e != null) {
  //         sliderCurrentPosition = e.currentPosition;
  //         maxDuration = e.duration;

  //         DateTime date = new DateTime.fromMillisecondsSinceEpoch(
  //             e.currentPosition.toInt(),
  //             isUtc: true);
  //         String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
  //         this.setState(() {
  //           this.playerTxt = txt.substring(0, 8);
  //         });
  //       }
  //     });
  //   } catch (err) {
  //     print('error: $err');
  //   }
  //   // setState(() {});
  // }

  // void stopPlayer() async {
  //   try {
  //     String result = await widget.flutterSound.stopPlayer();
  //     print('stopPlayer: $result');
  //     if (_playerSubscription != null) {
  //       _playerSubscription.cancel();
  //       _playerSubscription = null;
  //     }
  //     this.setState(() {
  //       sliderCurrentPosition = 0.0;
  //     });
  //   } catch (err) {
  //     print('error: $err');
  //   }
  // }

  // void pausePlayer() async {
  //   String result;
  //   try {
  //     if (widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED) {
  //       result = await widget.flutterSound.resumePlayer();
  //       print('resumePlayer: $result');
  //     } else {
  //       result = await widget.flutterSound.pausePlayer();
  //       print('pausePlayer: $result');
  //     }
  //   } catch (err) {
  //     print('error: $err');
  //   }
  //   setState(() {});
  // }

  // void seekToPlayer(int milliSecs) async {
  //   if (widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING) {
  //     await widget.flutterSound.seekToPlayer(milliSecs);
  //     // print('seekToPlayer: $result');
  //   }
  // }

  // onPausePlayerPressed() {
  //   return widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
  //           widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
  //       ? pausePlayer()
  //       : null;
  // }

  // onStopPlayerPressed() {
  //   return widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
  //           widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
  //       ? stopPlayer()
  //       : null;
  // }

  // onStartPlayerPressed(String voiceUrl) {
  //   if (voiceUrl == null) return null;
  //   return widget.flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
  //       ? startPlayer(voiceUrl)
  //       : pausePlayer();
  // }

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
              ? _textWidget(color: textColor)
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
                            color: textColor,
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
                            color: textColor,
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
            color: color ?? primaryColor,
            borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  // _userPhoto() {
  //   return Container(
  //     margin: EdgeInsets.only(right: 8.0),
  //     child: Material(
  //       child: CachedNetworkImage(
  //         placeholder: (context, url) => Container(
  //           child: CircularProgressIndicator(
  //             strokeWidth: 1.0,
  //             valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
  //           ),
  //           // width: 35.0,
  //           // height: 35.0,
  //         ),
  //         // imageUrl: widget.document['photoFrom'],
  //         width: 35.0,
  //         height: 35.0,
  //         fit: BoxFit.cover,
  //       ),
  //       borderRadius: BorderRadius.all(
  //         Radius.circular(18.0),
  //       ),
  //       clipBehavior: Clip.hardEdge,
  //     ),
  //   );
  // }

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
          // if (images.length > 4 && index == 3) {
          //   return InkWell(
          //     onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) =>
          //             FullPhoto(images: images, index: index))),
          //     child: Container(
          //       height: _imgSize,
          //       width: _imgSize,
          //       margin: EdgeInsets.all(5.0),
          //       decoration: BoxDecoration(
          //           color: Colors.grey.shade600,
          //           borderRadius: BorderRadius.circular(5.0)),
          //       child: Center(
          //         child: Text(
          //           '+${images.length - 3}',
          //           style: TextStyle(color: Colors.white, fontSize: 25.0),
          //         ),
          //       ),
          //     ),
          //   );
          // } else if (images.length > 4 && index > 3) {
          //   return SizedBox();
          // }
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
                            await myTransaction
                                .delete(widget.document['images']);
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
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
      return _textWidget(color: primaryColor);
    } else if (widget.document['type'] == 1) {
      //img
      return _imagesWidget();
    }

    // else if (widget.document['type'] == 2) {
    //   // stickers
    //   return _stickerWidget();
    // } else if (widget.document['type'] == 3) {
    //   // record
    //   return _voiceContainer(
    //       widget.document['content'], widget.document['recorderTime']);
    // }
    return Container();
  }

  // _stickerWidget() {
  //   return Container(
  //     child: Image.asset(
  //       'images/${widget.document['content']}.gif',
  //       width: 100.0,
  //       height: 100.0,
  //       fit: BoxFit.cover,
  //     ),
  //   );
  // }

  // _voiceContainer(String voiceUrl, String recorderTime) {
  //   return Container(
  //     // width: MediaQuery.of(context).size.width * 0.55,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8.0),
  //       color: textColor,
  //     ),
  //     child: Row(
  //       children: <Widget>[
  //         // IconButton(
  //         //     icon: Icon(
  //         //       widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING
  //         //           ? Icons.stop
  //         //           : Icons.play_arrow,
  //         //       color: Colors.white,
  //         //       size: 35.0,
  //         //     ),
  //         //     onPressed: () => onStartPlayerPressed(voiceUrl)),
  //         Container(
  //             child: SliderTheme(
  //           data: SliderTheme.of(context).copyWith(
  //             activeTrackColor: thirdColor,
  //             inactiveTrackColor: Colors.grey,
  //             thumbColor: thirdColor,
  //             thumbShape: RoundSliderThumbShape(
  //               enabledThumbRadius: 7.0,
  //             ),
  //           ),
  //           child: Container(
  //             width: 250.0,
  //             child: Column(
  //               children: <Widget>[
  //                 // Slider(
  //                 //       value: sliderCurrentPosition,
  //                 //       // inactiveColor: thirdColor,
  //                 //       // activeColor: primaryColor,
  //                 //       min: 0.0,
  //                 //       max: maxDuration,
  //                 //       onChanged: (double value) => seekToPlayer(value.toInt()),
  //                 //       divisions: maxDuration.toInt()),
  //                 Container(
  //                   padding: EdgeInsets.symmetric(horizontal: 16.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: <Widget>[
  //                       Text(
  //                         '$playerTxt',
  //                         style: TextStyle(color: thirdColor),
  //                       ),
  //                       Text(
  //                         '$recorderTime',
  //                         style: TextStyle(color: thirdColor),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   height: 5.0,
  //                 )
  //               ],
  //             ),
  //           ),
  //         )),
  //       ],
  //     ),
  //   );
  // }
}
