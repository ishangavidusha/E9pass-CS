import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e9pass_cs/models/appSettings.dart';
import 'package:e9pass_cs/repository/authService.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsProvider settingsProvider;
  FirebaseUser currentUser;
  AuthService authService;
  String sheetUrl;
  bool isSwitched;
  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    double devHeight = MediaQuery.of(context).size.height;
    settingsProvider = Provider.of<SettingsProvider>(context);
    authService = Provider.of<AuthService>(context);
    isSwitched = settingsProvider.appSettings?.upload == null ? false : settingsProvider.appSettings.upload;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              width: devWidth,
              height: devHeight,
              color: AppColors.backgroundColor,
            ),
          ),
          Positioned(
            child: Container(
              alignment: Alignment.bottomCenter,
              width: devWidth,
              height: devHeight * 0.12,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: devHeight * 0.15,
            child: Container(
              width: devWidth,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Add Sheet URL',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: 100,
                        child: Text(
                          settingsProvider.appSettings != null ? settingsProvider.appSettings.sheetUrl != null ? settingsProvider.appSettings.sheetUrl : 'Not Set' : 'Not Set',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTextColor,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: 150,
                        height: 40,
                        child: KButton(
                          text: 'Edit URL',
                          linearGradient: AppColors.linearGradient,
                          onPressed: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.NO_HEADER,
                              animType: AnimType.BOTTOMSLIDE,
                              body: TextField(
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: 'Sheet Url',
                                  hintText: 'http//:....',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                textInputAction: TextInputAction.done,
                                onChanged: (value) {
                                  setState(() {
                                    sheetUrl = value;
                                  });
                                },
                                onSubmitted: (value) async {
                                  setState(() {
                                    sheetUrl = value;
                                  });
                                },
                              ),
                              btnOkText: 'Done',
                              btnOkOnPress: () async {
                                if (sheetUrl != null && sheetUrl.length > 0) {
                                  AppSettings appSettings = await settingsProvider.getSettings('settings');
                                  if (appSettings == null) {
                                    appSettings = AppSettings(
                                      country: 'SL',
                                      upload: true,
                                      sheetUrl: sheetUrl
                                    );
                                  } else {
                                    appSettings.sheetUrl = sheetUrl;
                                    appSettings.upload = true;
                                  }
                                  bool result = await settingsProvider.setSettings('settings', appSettings);
                                  if (result) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.SUCCES,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: 'Succes',
                                      desc: 'Settings Saved',
                                      btnOkText: 'Done',
                                      btnOkOnPress: () {
                                        // pop
                                      },
                                      onDissmissCallback: () {

                                      }
                                    )..show();
                                  } else {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.ERROR,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: 'Faild',
                                      desc: 'Faild to save URL',
                                      btnOkText: 'Done',
                                      btnOkOnPress: () {
                                        // pop
                                      },
                                      onDissmissCallback: () {

                                      }
                                    )..show();
                                  }
                                }
                              },
                              onDissmissCallback: () {

                              }
                            )..show();
                          },
                          icon: Icon(Icons.edit, color: Colors.white,),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upload ON/OFF',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTextColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) async {
                            AppSettings appSettings = await settingsProvider.getSettings('settings');
                            if (appSettings == null) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.ERROR,
                                animType: AnimType.BOTTOMSLIDE,
                                title: 'Faild',
                                desc: 'URL not found. Set Url first',
                                btnOkText: 'Done',
                                btnOkOnPress: () {
                                  // pop
                                },
                                onDissmissCallback: () {

                                }
                              )..show();
                            } else {
                              appSettings.upload = value;
                              bool result = await settingsProvider.setSettings('settings', appSettings);
                              if (result) {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.SUCCES,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Succes',
                                  desc: 'Settings Saved',
                                  btnOkText: 'Done',
                                  btnOkOnPress: () {
                                    // pop
                                  },
                                  onDissmissCallback: () {

                                  }
                                )..show();
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.ERROR,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Faild',
                                  desc: 'Faild to set Upload',
                                  btnOkText: 'Done',
                                  btnOkOnPress: () {
                                    // pop
                                  },
                                  onDissmissCallback: () {

                                  }
                                )..show();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  authService.currentUser != null ? Container(
                    width: devWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            Container(
                              width: devWidth * 0.3,
                              height: devWidth * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.buttonShadowColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.buttonShadowColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 6)
                                  )
                                ]
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(devWidth * 0.025),
                              width: devWidth * 0.25,
                              height: devWidth * 0.25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                                image: DecorationImage(
                                  image: NetworkImage(authService.currentUser.photoUrl),
                                )
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          authService.currentUser.displayName,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTextColor,
                            ),
                          ),
                        ),
                        Text(
                          authService.currentUser.email,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTextColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ) : Container()
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              width: devWidth,
              height: 50,
              child: authService.currentUser == null ? KButton(
                text: 'LogIn',
                onPressed: () async {
                  authService.signInWithGoogle();
                },
                icon: Icon(Icons.power, color: Colors.white,),
                linearGradient: AppColors.linearGradient,
              ) : KButton(
                text: 'LogOut',
                onPressed: () async {
                  authService.signOutGoogle();
                },
                icon: Icon(Icons.power, color: Colors.white,),
                linearGradient: AppColors.linearGradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

