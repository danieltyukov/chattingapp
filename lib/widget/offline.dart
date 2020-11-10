import 'package:flutter/material.dart';

Widget offlinescreen(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              "assets/images/teacup.png",
              height: 200,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            child: Text(
              'No Internet Connection...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    ),
  );
}
