import 'package:chattingapp/views/blog_home.dart';
import 'package:chattingapp/views/chatrooms.dart';
import 'package:chattingapp/views/grouppage.dart';
import 'package:chattingapp/views/profiledisplay.dart';
import 'package:chattingapp/views/report.dart';
import 'package:chattingapp/views/snake.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget drawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: const Color(0xff0C1C3E),
          ),
          child: Image.asset(
            "assets/images/chatapplogo.png",
            height: 200,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.group),
            title: Text('Groups'),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogHomePage(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('News'),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SnakeGame(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.games),
            title: Text('Snake Game'),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainProfilePage(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(),
              ),
            );
          },
          child: ListTile(
            leading: Icon(Icons.report),
            title: Text('Report Error'),
          ),
        ),
      ],
    ),
  );
}
