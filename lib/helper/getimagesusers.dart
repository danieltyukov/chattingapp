import 'package:aspireapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GetImagesUsers extends StatefulWidget {
  String userName;
  GetImagesUsers(this.userName);

  @override
  _GetImagesUsersState createState() => _GetImagesUsersState();
}

class _GetImagesUsersState extends State<GetImagesUsers> {
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
              .where('userName', isEqualTo: widget.userName)
              .snapshots(),
          // ignore: missing_return
          builder: (ctx, profileSnapshot) {
            
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final profileDocs =
                profileSnapshot.data.documents[0].data['image_url'];
            
            if (profileDocs != null) {
              return Image.network(profileDocs, fit: BoxFit.fill,
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
              return Center(
                child: Text(widget.userName.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w300)),
              );
            }
          },
        );
      },
    );
  }
}
