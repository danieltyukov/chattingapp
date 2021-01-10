import 'package:chattingapp/widget/drawer.dart';
import 'package:flutter/material.dart';
//this page is for people to write personal
//suggestions,errors,reports

class ReportPage extends StatelessWidget {
  const ReportPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Report',
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
        // elevation: 0.0,
        // centerTitle: false,
      ),
      drawer: drawer(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                "assets/images/report.png",
                height: 200,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text(
                'Report Any Error That You Find:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              child: Text(
                'Daniel Tyukov: contact@danieltyukov.com',
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
}
