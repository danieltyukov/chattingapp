import 'package:aspireapp/services/crud.dart';
import 'package:aspireapp/services/database.dart';
import 'package:aspireapp/views/blog_create.dart';
import 'package:aspireapp/views/blog_full.dart';
import 'package:aspireapp/widget/drawer.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class BlogHomePage extends StatefulWidget {
  @override
  _BlogHomePageState createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  CrudMethods cruedMethods = new CrudMethods();

  Stream blogsStream;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods databaseMethods = DatabaseMethods();

  FirebaseUser user;

  initUser() async {
    user = await _auth.currentUser();

    setState(() {});
  }

  // ignore: non_constant_identifier_names
  Widget BlogList() {
    return Container(
      child: blogsStream != null
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: blogsStream,
                    builder: (context, snapshot) {
                      //
                      if (snapshot.hasError) {
                        return Text(snapshot.error);
                      }
                      if (snapshot.data == null)
                        return SizedBox(
                            height: MediaQuery.of(context).size.height / 1.3,
                            child: Center(child: CircularProgressIndicator()));

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: snapshot.data.documents.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return BlogsTile(
                            authorName: snapshot
                                .data.documents[index].data["authorName"],
                            title: snapshot.data.documents[index].data["title"],
                            description:
                                snapshot.data.documents[index].data["desc"],
                            imgUrl:
                                snapshot.data.documents[index].data["imageUrl"],
                            index: index,
                            snapshot: snapshot,
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void initState() {
    initUser();
    cruedMethods.getData().then((result) {
      setState(() {
        blogsStream = result;
      });
    });
    super.initState();
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
                  'Aspire',
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
          ),
          drawer: drawer(context),
          body: BlogList(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:
              '${user?.email}' == 'principal@aspireschool.ac.cy' ||
                      '${user?.email}' == 'daniel.tyu@aspireschool.com'
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateBlog(),
                            ),
                          );
                        },
                        child: Icon(Icons.add),
                      ),
                    )
                  : null),
    );
  }
}

// ignore: must_be_immutable
class BlogsTile extends StatelessWidget {
  String imgUrl, title, description, authorName;
  final AsyncSnapshot<dynamic> snapshot;
  final int index;
  BlogsTile({
    @required this.authorName,
    @required this.description,
    @required this.imgUrl,
    @required this.title,
    @required this.snapshot,
    @required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Delete The News'),
                content: Text('You Will Not Be Able To Recover It.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Firestore.instance
                          .runTransaction((Transaction myTransaction) async {
                        await myTransaction
                            .delete(snapshot.data.documents[index].reference);
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullBlog(
              description: description,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        height: 170,
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                )),
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.black45.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    authorName,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
