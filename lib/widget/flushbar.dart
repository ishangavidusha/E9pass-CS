import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showFloatingFlushbar(BuildContext context, String err, bool result) {
    Flushbar(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(seconds: 3),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: result ? 'Success!' : 'Failed!',
      message: err,
      icon: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: result ? Image.asset(
          'assets/images/correct-round.png',
          fit: BoxFit.contain,
        ) : Image.asset(
          'assets/images/criss-cross.png',
          fit: BoxFit.contain,
        )
      ),
    )..show(context);
  }