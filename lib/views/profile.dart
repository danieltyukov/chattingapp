import 'package:chattingapp/helper/constants.dart';
import 'package:chattingapp/helper/theme.dart';
import 'package:chattingapp/services/database.dart';
import 'package:chattingapp/widget/offline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();

  User user;
  File _image;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = _auth.currentUser;

    setState(() {});
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
          .child('user_image')
          .child(user.uid + '.jpg');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image);
      //MIGHT CAUSE AN ERROR
      TaskSnapshot taskSnapshot = await uploadTask;
      final url = await taskSnapshot.ref.getDownloadURL();
      databaseMethods.addImage(url, user.uid);

      setState(() {
        print("Profile Picture Uploaded");
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Picture Uploaded'),
          ),
        );
      });
    }

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
              icon: Icon(FontAwesomeIcons.arrowLeft),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text('Edit Profile'),
        ),
        body: Builder(
          builder: (context) => Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Color(0xff0C1C3E),
                        child: ClipOval(
                          child: SizedBox(
                            width: 180.0,
                            height: 180.0,
                            child: (_image != null)
                                ? Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: CustomTheme.colorAccent,
                                    ),
                                    child: Text(
                                        Constants.myName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 100,
                                            fontFamily: 'OverpassRegular',
                                            fontWeight: FontWeight.w900)),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.camera,
                          size: 30.0,
                          color: Color(0xff036240),
                        ),
                        onPressed: () {
                          getImage();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Email:',
                          style: TextStyle(
                              color: Colors.blueGrey, fontSize: 18.0)),
                      SizedBox(width: 7.0),
                      Text("${user?.email}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.0,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Name:',
                          style: TextStyle(
                              color: Colors.blueGrey, fontSize: 18.0)),
                      SizedBox(width: 7.0),
                      Text("${Constants.myName}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      color: Color(0xff036240),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                    RaisedButton(
                      color: Color(0xff036240),
                      onPressed: () {
                        uploadPic(context);
                      },
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
