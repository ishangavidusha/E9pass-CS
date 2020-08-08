import 'package:e9pass_cs/repository/authService.dart';
import 'package:e9pass_cs/state/fileProvider.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/views/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'views/homeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(create: (context) => SettingsProvider()),
        ChangeNotifierProvider<FileProvider>(create: (context) => FileProvider()),
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E9pass CS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          canvasColor: Colors.transparent,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

