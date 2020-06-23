import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class KButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final LinearGradient linearGradient;
  final Icon icon;
  final bool navigate;
  final bool busy;

  const KButton({Key key, this.text, this.onPressed, this.linearGradient, this.icon, this.navigate, this.busy}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: RaisedButton(
        onPressed: onPressed,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: linearGradient,
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: icon,
                ),
                !busy ? Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ) : Center(
                  child: ScalingText(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
