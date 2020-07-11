import 'package:aspireapp/services/auth.dart';
import 'package:aspireapp/widget/widget.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailEditingController = new TextEditingController();
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            controller: emailEditingController,
            style: simpleTextStyle(),
            validator: (val) {
              return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val)
                  ? null
                  : "Enter correct email";
            },
            decoration: textFieldInputDecoration("email"),
          ),
          GestureDetector(
            onTap: () async {
              await authService.resetPass(emailEditingController.text);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [const Color(0xff007EF4), const Color(0xff2A75BC)],
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
    );
  }
}
