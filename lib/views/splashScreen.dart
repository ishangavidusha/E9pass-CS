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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Fatching Data...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data.length < 1) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Error Fatching Data!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'Check your Internet Conection',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return HomeScreen();
              }
            },
          ),
        ],
      ),
    );
  }
}