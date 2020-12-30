import 'package:chattingapp/widget/offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

// ignore: must_be_immutable
class FullBlog extends StatefulWidget {
  String title, description;
  FullBlog({@required this.description, @required this.title});

  @override
  _FullBlogState createState() => _FullBlogState();
}

class _FullBlogState extends State<FullBlog> {
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
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Center(
                  heightFactor: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${widget.title}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                child: Center(
                  heightFactor: 1,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Text(
                      '${widget.description}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
