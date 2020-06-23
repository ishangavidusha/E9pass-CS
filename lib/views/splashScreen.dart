import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Center(
          child: JumpingDotsProgressIndicator(
              fontSize: 36.0,
            ),
        ),
      )
    );
  }
}