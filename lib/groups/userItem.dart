import 'package:chattingapp/helper/theme.dart';

import 'package:flutter/material.dart';
import 'userModel.dart';

class UserItem extends StatelessWidget {
  final Function onPressed;
  final UserModel user;
  const UserItem({this.onPressed, this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: Container(
                child: Text(user.userName.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: CustomTheme.primaryColor,
                        fontSize: 16,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${user.userName}',
                        style: TextStyle(color: Colors.white),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
