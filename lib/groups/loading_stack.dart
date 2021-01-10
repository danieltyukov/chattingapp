import 'package:chattingapp/helper/theme.dart';
import 'package:flutter/material.dart';

class LoadingStack extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  LoadingStack({@required this.child, @required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primaryColor),
                    ),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : SizedBox(),
        )
      ],
    );
  }
}
