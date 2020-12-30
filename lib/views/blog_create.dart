import 'dart:io';

import 'package:chattingapp/services/crud.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlog extends StatefulWidget {
  CreateBlog({Key key}) : super(key: key);

  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String authorName, title, desc;
  File selectedImage;
  bool _isLoading = false;

  CrudMethods crudMethods = new CrudMethods();

  Future getImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  uploadBlog() async {
    if (selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      ///upload image to firestore
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('blogImages')
          .child('${randomAlphaNumeric(9)}.jpg');

      final UploadTask task = firebaseStorageRef.putFile(selectedImage);
      //MIGHT CAUSE ERROR onComplete
      var downloadUrl = await (await task).ref.getDownloadURL();
      print('$downloadUrl');
      Map<String, dynamic> blogMap = {
        "authorName": authorName,
        "desc": desc,
        "imageUrl": downloadUrl,
        "title": title,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      crudMethods.addData(blogMap).then((result) {
        Navigator.pop(context);
      });
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please Fill In Everything'),
            content: Text(
                'Could You Please Fill In All The Bottom Fields. (Including The Image)'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
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
                'Chat',
                style: TextStyle(fontSize: 22),
              ),
              Text(
                'News',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.lightBlue,
                ),
              )
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                uploadBlog();
              },
              child: Container(
                child: Icon(Icons.file_upload),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: selectedImage != null
                            ? Container(
                                height: 170,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    selectedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 16),
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                height: 170,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                width: MediaQuery.of(context).size.width,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.black45,
                                ),
                              ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            new Theme(
                              data: new ThemeData(
                                  primaryColor: Colors.blueGrey,
                                  accentColor: Colors.blueGrey,
                                  hintColor: Colors.blueGrey),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Author Name',
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onChanged: (val) {
                                  authorName = val;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(40)
                                ],
                              ),
                            ),
                            new Theme(
                              data: new ThemeData(
                                  primaryColor: Colors.blueGrey,
                                  accentColor: Colors.blueGrey,
                                  hintColor: Colors.blueGrey),
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueGrey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                onChanged: (val) {
                                  title = val;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                              ),
                            ),
                            new Theme(
                              data: new ThemeData(
                                  primaryColor: Colors.blueGrey,
                                  accentColor: Colors.blueGrey,
                                  hintColor: Colors.blueGrey),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.only(bottom: 40, top: 10),
                                    hintText: 'Description',
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueGrey),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blueGrey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    desc = val;
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10000)
                                  ],
                                ),
                              ),
                            ),
                          ],
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
