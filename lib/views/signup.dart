import 'dart:math';

import 'package:aspireapp/helper/authenticate.dart';
import 'package:aspireapp/helper/helperfunctions.dart';
import 'package:aspireapp/services/auth.dart';
import 'package:aspireapp/services/database.dart';
import 'package:aspireapp/views/chatrooms.dart';
import 'package:aspireapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  static var specialId;

  singUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then(
        (result) {
          if (result != null) {
            Map<String, String> userDataMap = {
              "userName": usernameEditingController.text,
              "userEmail": emailEditingController.text,
              "image_url": null,
            };

            const _chars =
                'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
            Random _rnd = Random();

            String getRandomString(int length) =>
                String.fromCharCodes(Iterable.generate(length,
                    (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
            var userSpecialId = getRandomString(20);
            specialId = userSpecialId;

            databaseMethods.addUserInfo(userDataMap, specialId);

            HelperFunctions.saveUserLoggedInSharedPreference(true);
            HelperFunctions.saveUserNameSharedPreference(
                usernameEditingController.text);
            HelperFunctions.saveUserEmailSharedPreference(
                emailEditingController.text);

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Authenticate()));
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: simpleTextStyle(),
                          controller: usernameEditingController,
                          validator: (val) {
                            final hasDataName = val.isNotEmpty;
                            String result = val.split(" ").join("-");
                            print(result);
                            final nameCheck = result.contains('-');
                            final fullName = result.length > 4;
                            final nameValid =
                                RegExp(r'^[a-zA-Z0\-]+$').hasMatch(result);
                            final finalName = result.split("-").join(" ");
                            print(finalName);
                            val = finalName;
                            if (nameValid &&
                                hasDataName &&
                                fullName &&
                                nameCheck) {
                              return null;
                            } else {
                              return "Enter Your Name And Surname Separated By Space";
                            }
                          },
                          decoration: textFieldInputDecoration("full name"),
                        ),
                        TextFormField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            final aspireVal = val.contains('aspire-school');
                            final regResult =
                                RegExp(r"^[a-zA.]+@[a-zA.-]+\.[a-zA]+")
                                    .hasMatch(val);
                            final hasData = val.isNotEmpty;
                            if (regResult && hasData && aspireVal) {
                              return null;
                            } else {
                              return 'Has To Be Your Valid Aspire Email';
                            }
                          },
                          decoration: textFieldInputDecoration("aspire email"),
                        ),
                        TextFormField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          controller: passwordEditingController,
                          validator: (val) {
                            final passCharacters =
                                RegExp(r'^[a-zA-Z0-9&%=]+$').hasMatch(val);
                            final hasDataPass = val.isNotEmpty;
                            bool lengthCheck = val.length > 6;
                            if (passCharacters && hasDataPass && lengthCheck) {
                              return null;
                            } else {
                              return "Has To Be 6+ Characters And Only (alphanumeric and &%=) Accepted";
                            }
                          },
                          decoration: textFieldInputDecoration("password"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final valid = await databaseMethods
                          .usernameCheck(usernameEditingController.text);
                      if (!valid) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Authenticate(),
                          ),
                        );
                      } else {
                        singUp();
                      }
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
                          )),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign Up",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "SignIn now",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
    );
  }
}
