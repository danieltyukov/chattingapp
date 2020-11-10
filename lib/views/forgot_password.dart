import 'package:aspireapp/services/auth.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:aspireapp/widget/widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailEditingController = new TextEditingController();
  AuthService authService = AuthService();
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
        appBar: appBarMain(context),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailEditingController,
                style: simpleTextStyle(),
                validator: (val) {
                  final regResult = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val);
                  final hasData = val.isNotEmpty;
                  final aspireVal = val.contains('aspire');
                  if (regResult && hasData && aspireVal) {
                    return null;
                  } else {
                    return "Enter Your Correct Email";
                  }
                },
                decoration: textFieldInputDecoration("Email"),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    print(
                        "Email Has Been Sent To: ${emailEditingController.text}");

                    Flushbar(
                      title: "Password Reset",
                      message: "The Password Reset Has Been Sent To Your Email",
                      duration: Duration(seconds: 3),
                    )..show(context);
                  });
                  await authService.resetPass(emailEditingController.text);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff007EF4),
                        const Color(0xff2A75BC)
                      ],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Reset Password",
                    style: biggerTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
