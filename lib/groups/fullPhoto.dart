import 'package:chattingapp/widget/offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class FullPhoto extends StatelessWidget {
  final List images;
  final int index;

  FullPhoto({@required this.images, @required this.index});

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
        body: FullPhotoScreen(index: index, images: images),
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final int index;
  final List images;

  FullPhotoScreen({Key key, @required this.index, @required this.images})
      : super(key: key);

  @override
  State createState() => new FullPhotoScreenState();
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  int currentIndex;
  // bool verticalGallery = true;
  PageController page;

  @override
  void initState() {
    page = PageController(initialPage: widget.index);
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
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.images[0]),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: null,
          ),
        ),
      ),
    );
  }
}
