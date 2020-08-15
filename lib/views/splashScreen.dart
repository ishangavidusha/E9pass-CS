import 'package:e9pass_cs/models/fireSettings.dart';
import 'package:e9pass_cs/repository/dbService.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/views/homeScreen.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataRepository dataRepository;

  @override
  void didChangeDependencies() {
    Provider.of<SettingsProvider>(context, listen: false).getSettings('settings');
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    double devHeight = MediaQuery.of(context).size.height;
    dataRepository ??= Provider.of<DataRepository>(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: devHeight,
              width: devWidth,
              color: AppColors.backgroundColor,
            ),
          ),
          FutureBuilder(
            future: dataRepository != null ? dataRepository.getData(shouldUpdate: false) : null,
            builder: (BuildContext context, AsyncSnapshot<List<AppData>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data.length < 1) {
                return Center(
                  child: Text('Error Fatching Data!'),
                );
              } else {
                print(snapshot.data.length);
                return HomeScreen();
              }
            },
          ),
        ],
      ),
    );
  }
}