import 'package:aspireapp/helper/authenticate.dart';
import 'package:aspireapp/helper/helperfunctions.dart';
import 'package:aspireapp/services/auth.dart';
import 'package:aspireapp/services/database.dart';
import 'package:aspireapp/views/chatrooms.dart';
import 'package:aspireapp/widget/offline.dart';
import 'package:aspireapp/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

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
          print('$result');
          print('HERE IS WHAT YOUR LOOKING FOR');
          if (result != null) {
            Map<String, String> userDataMap = {
              "userName": usernameEditingController.text,
              "userEmail": emailEditingController.text,
            };

            databaseMethods.addUserInfo(userDataMap, result);

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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Aspire',
                  style: TextStyle(fontSize: 22),
                ),
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.lightBlue,
                  ),
                )
              ],
            ),
            elevation: 0.0,
            centerTitle: false,
            automaticallyImplyLeading: false),
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                              final finalfinalName = finalName
                                  .split(' ')
                                  .map((word) =>
                                      word[0].toUpperCase() + word.substring(1))
                                  .join(' ');
                              final lastCheck = finalName == finalfinalName;
                              print(finalfinalName);
                              val = finalfinalName;
                              print(val);
                              if (nameValid &&
                                  hasDataName &&
                                  fullName &&
                                  nameCheck &&
                                  lastCheck) {
                                return null;
                              } else {
                                return "Enter Your Name And Surname e.g(Daniel Tyukov)";
                              }
                            },
                            decoration: textFieldInputDecoration("Full Name"),
                          ),
                          TextFormField(
                            controller: emailEditingController,
                            style: simpleTextStyle(),
                            validator: (val) {
                              final aspireVal = val.contains('aspire');
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
                            decoration:
                                textFieldInputDecoration("Aspire Email"),
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
                              if (passCharacters &&
                                  hasDataPass &&
                                  lengthCheck) {
                                return null;
                              } else {
                                return "Has To Be 6+ and (alphanumeric and &%=) Accepted";
                              }
                            },
                            decoration: textFieldInputDecoration("Password"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                        padding: EdgeInsets.symmetric(vertical: 15),
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
                      height: 15,
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
                            "Sign In Now",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            "Created By: Daniel Tyukov",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
