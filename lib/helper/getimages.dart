import 'package:aspireapp/helper/constants.dart';
import 'package:aspireapp/helper/theme.dart';
import 'package:aspireapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetImages extends StatefulWidget {
  @override
  _GetImagesState createState() => _GetImagesState();
}

class _GetImagesState extends State<GetImages> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseMethods databaseMethods = DatabaseMethods();

  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          //snapshot allows the stream to happen we set up a screen
          stream: Firestore.instance
              .collection('users')
              .document('${user.uid}')
              .snapshots(),
          // ignore: missing_return
          builder: (ctx, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final profileDocs = profileSnapshot.data;
            //builds the text messages
            // print(profileDocs['image_url']);
            if (profileDocs['image_url'] != null) {
              Constants.imagePath = profileDocs['image_url'];
              return Image.network(profileDocs['image_url'], fit: BoxFit.fill,
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
              });
            } else {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CustomTheme.colorAccent,
                ),
                child: Text(Constants.myName.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w900)),
              );
            }
          },
        );
      },
    );
  }
}
