import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e9pass_cs/models/appSettings.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsProvider settingsProvider;
  String sheetUrl;
  bool isSwitched;
  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    double devHeight = MediaQuery.of(context).size.height;
    settingsProvider = Provider.of<SettingsProvider>(context);
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
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
                        width: 150,
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

