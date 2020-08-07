import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e9pass_cs/models/appSettings.dart';
import 'package:e9pass_cs/models/sheetModel.dart';
import 'package:e9pass_cs/repository/cameraService.dart';
import 'package:e9pass_cs/repository/fileService.dart';
import 'package:e9pass_cs/repository/pdfFactory.dart';
import 'package:e9pass_cs/repository/sheetService.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/views/settingsView.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PDFCreaterView extends StatefulWidget {
  @override
  _PDFCreaterViewState createState() => _PDFCreaterViewState();
}

class _PDFCreaterViewState extends State<PDFCreaterView> {
  ScrollController _scrollController;
  Animation<double> topBarAnimation;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CamService _camService = CamService();
  PdfFactory _pdfFactory = PdfFactory();
  FileService _fileService = FileService();
  SheetService _sheetService = SheetService();
  bool showTitleBar = false;
  double topBarOpacity = 0.0;
  pw.Document pdf;
  File arcImage;
  File personImage;
  String appNumber;
  String name;
  String arcNumber;
  String phoneNumber;
  bool saving = false;
  SettingsProvider settingsProvider;
  SettingsProvider mySettingsProvider;
  AppSettings appSettings;
  bool isSwitched;

  Future<Map<String, dynamic>> savePdfAndPhotos() async {
    try {
      pdf = await _pdfFactory.getPdfFile(
          arcImage, personImage, name, arcNumber, phoneNumber, appNumber);
      bool result = await _fileService.savePdfLocale(pdf, appNumber);
      if (!result) {
        return {"state": false, "msg": 'Error occurred during Saving PDF'};
      }
      if (arcImage != null) {
        await _fileService.saveImageToDownload(arcImage, '$appNumber-ARC');
      }
      if (personImage != null) {
        await _fileService.saveImageToDownload(
            personImage, '$appNumber-Person');
      }
      return {"state": true, "msg": 'Done'};
    } catch (error) {
      return {"state": false, "msg": error};
    }
  }

  Future<bool> sheetUpload(String sheetUrl) async {
    SheetModel sheetModel = SheetModel(
        name: name ?? 'null',
        applicationNumber: appNumber ?? 'null',
        arcNumber: arcNumber ?? 'null',
        phoneNumber: phoneNumber ?? 'null');
    try {
      String result = await _sheetService.submitData(sheetModel, sheetUrl);
      if (result == "SUCCESS") {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
    }
    return false;
  }

  void resetData() {
    setState(() {
      _formKey.currentState.reset();
      pdf = null;
      arcImage = null;
      personImage = null;
      appNumber = null;
      name = null;
      arcNumber = null;
      phoneNumber = null;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scroollListener);
    settingsProvider ??= Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.getSettings('settings');
    super.initState();
  }

  scroollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (_scrollController.offset <= 24 &&
          _scrollController.offset >= 0) {
        if (topBarOpacity != _scrollController.offset / 24) {
          setState(() {
            topBarOpacity = _scrollController.offset / 24;
          });
        }
      } else if (_scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    double devHeight = MediaQuery.of(context).size.height;
    mySettingsProvider = Provider.of<SettingsProvider>(context);
    isSwitched = settingsProvider.appSettings?.upload == null
        ? false
        : settingsProvider.appSettings.upload;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Positioned(
            child: Container(
              width: devWidth,
              height: devHeight,
              color: AppColors.backgroundColor,
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: devHeight * 0.13,
                ),
                Container(
                  width: devWidth,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ARC / Passport Photo',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainTextColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                              gradient: AppColors.linearGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF438AFE).withOpacity(0.4),
                                  offset: Offset(0.0, 10),
                                  blurRadius: 15,
                                ),
                              ]),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            arcImage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  width: devWidth * 0.8,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 8),
                          blurRadius: 10,
                          color: Colors.blueGrey.withOpacity(0.2),
                        ),
                      ]),
                  child: arcImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            arcImage,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Image.asset(
                            'assets/images/id-card.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: KButton(
                    text: 'ARC / Passport',
                    onPressed: () {
                      getArcImage(devHeight, devWidth);
                    },
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                      colors: [
                        Color(0xFF1D73FF),
                        Color(0xFF438AFE),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: devWidth,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Person\'s Verification Photo',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainTextColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              gradient: AppColors.linearGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF438AFE).withOpacity(0.4),
                                  offset: Offset(0.0, 10),
                                  blurRadius: 15,
                                ),
                              ]),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            personImage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  width: devWidth * 0.8,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 8),
                          blurRadius: 10,
                          color: Colors.blueGrey.withOpacity(0.2),
                        ),
                      ]),
                  child: personImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            personImage,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Image.asset(
                            'assets/images/login.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: KButton(
                    text: 'Verification Photo',
                    onPressed: () {
                      getPersonImage(devHeight, devWidth);
                    },
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                      colors: [
                        Color(0xFF1D73FF),
                        Color(0xFF438AFE),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: devWidth,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Application Number',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: devWidth * 0.8,
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 8),
                          blurRadius: 10,
                          color: Colors.blueGrey.withOpacity(0.2),
                        ),
                      ]),
                  child: Text(
                    appNumber != null ? appNumber : 'XXXXXX-XXXX-XXXX',
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.mainTextColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: KButton(
                    text: 'Scan Application Number',
                    onPressed: () {
                      getQrResult();
                    },
                    icon: Icon(
                      Icons.scanner,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                      colors: [
                        Color(0xFF1D73FF),
                        Color(0xFF438AFE),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: devWidth,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Personal Information',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: nameInput(),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: arcNumberInput(),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: phoneNumberInput(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: KButton(
                    text: 'Save PDF & Photos',
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (appNumber != null && appNumber.length > 0) {
                          if (arcImage != null || personImage != null) {
                            Map<String, dynamic> pdfResult;
                            setState(() {
                              saving = true;
                            });
                            if (isSwitched) {
                              appSettings = await settingsProvider
                                  .getSettings('settings');
                              if (appSettings.sheetUrl != null &&
                                  appSettings.sheetUrl.length > 0) {
                                bool result =
                                    await sheetUpload(appSettings.sheetUrl);
                                if (result) {
                                  pdfResult = await savePdfAndPhotos();
                                } else {
                                  pdfResult = await savePdfAndPhotos();
                                  SnackBar snackBar = SnackBar(
                                    content:
                                        Text('Failed to upload sheet data!'),
                                    duration: Duration(seconds: 3),
                                  );
                                  _scaffoldKey.currentState
                                      .showSnackBar(snackBar);
                                }
                              } else {
                                pdfResult = await savePdfAndPhotos();
                              }
                            } else {
                              pdfResult = await savePdfAndPhotos();
                            }
                            setState(() {
                              saving = false;
                            });
                            if (pdfResult['state'] == true) {
                              AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.SUCCES,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Succes',
                                  desc: 'PDF & Photos successfully saved',
                                  btnOkText: 'Clear',
                                  btnOkOnPress: () {
                                    resetData();
                                  },
                                  btnCancelText: 'Cancel',
                                  btnCancelOnPress: () {},
                                  onDissmissCallback: () {})
                                ..show();
                            } else {
                              AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.ERROR,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'Failed',
                                  desc: pdfResult['msg'],
                                  btnCancelText: 'Cancel',
                                  btnCancelOnPress: () {},
                                  onDissmissCallback: () {})
                                ..show();
                            }
                          } else {
                            AwesomeDialog(
                                context: context,
                                dialogType: DialogType.ERROR,
                                animType: AnimType.BOTTOMSLIDE,
                                title: 'Error',
                                desc: 'At least one photo should be included',
                                btnOkText: 'OK',
                                btnOkOnPress: () {},
                                onDissmissCallback: () {})
                              ..show();
                          }
                        } else {
                          AwesomeDialog(
                              context: context,
                              dialogType: DialogType.ERROR,
                              animType: AnimType.BOTTOMSLIDE,
                              title: 'Error',
                              desc: 'Pleace scan the application number',
                              btnOkText: 'Scan Now',
                              btnOkOnPress: () {
                                getQrResult();
                              },
                              btnCancelText: 'Cancel',
                              btnCancelOnPress: () {},
                              onDissmissCallback: () {})
                            ..show();
                        }
                      }
                    },
                    icon: Icon(
                      Icons.file_download,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                      colors: [
                        Color(0xFF1D73FF),
                        Color(0xFF438AFE),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.linearGradient,
                  ),
                  width: devWidth,
                  height: devHeight * 0.08,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        'Developed by',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'E9pay Remittance Sri Lanka',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor.withOpacity(topBarOpacity),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4 * topBarOpacity),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10 - 8.0 * topBarOpacity,
                      bottom: 8 - 8.0 * topBarOpacity,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'E9pass PDF Creater',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  devWidth * 0.045 + 6 - 6 * topBarOpacity,
                              color: AppColors.mainTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          saving
              ? Container(
                  width: devWidth,
                  height: devHeight,
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: Container(
                      width: devWidth * 0.25,
                      height: devWidth * 0.25,
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget nameInput() {
    return TextFormField(
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'ALSJR ALFJHSF',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelStyle: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value == '') {
          return 'Name Cannot Be Empty!';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        setState(() {
          name = value;
        });
      },
    );
  }

  Widget arcNumberInput() {
    return TextFormField(
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: 'ARC Number',
          hintText: '920802-XXXXXXX',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelStyle: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value == '') {
          return 'ARC Number Cannot Be Empty!';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        setState(() {
          arcNumber = value;
        });
      },
    );
  }

  Widget phoneNumberInput() {
    return TextFormField(
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: 'Phone Number',
          hintText: '010-7200-0988',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelStyle: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value == '') {
          return 'Phone Number Cannot Be Empty!';
        } else {
          return null;
        }
      },
      onChanged: (value) {
        setState(() {
          phoneNumber = value;
        });
      },
    );
  }

  Future getQrResult() async {
    String cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.QR);
    if (cameraScanResult != null && cameraScanResult.length > 4) {
      setState(() {
        appNumber = cameraScanResult;
      });
    } else {
      setState(() {
        appNumber = null;
      });
    }
  }

  void getArcImage(double devHeight, double devWidth) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: devHeight * 0.2,
            width: devWidth,
            color: Colors.transparent,
            child: new Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: new BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: devWidth * 0.5,
                      child: KButton(
                        onPressed: () async {
                          File imageFile =
                              await _camService.getImage(ImageSource.camera);
                          setState(() {
                            arcImage = imageFile;
                          });
                          Navigator.pop(context);
                        },
                        text: 'Camera',
                        icon: Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                        linearGradient: AppColors.linearGradient,
                      ),
                    ),
                    Container(
                      width: devWidth * 0.5,
                      child: KButton(
                        onPressed: () async {
                          File imageFile =
                              await _camService.getImage(ImageSource.gallery);
                          setState(() {
                            arcImage = imageFile;
                          });
                          Navigator.pop(context);
                        },
                        text: 'Gallery',
                        icon: Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        linearGradient: AppColors.linearGradient,
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  void getPersonImage(double devHeight, double devWidth) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: devHeight * 0.2,
            width: devWidth,
            color: Colors.transparent,
            child: new Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: new BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: devWidth * 0.5,
                      child: KButton(
                        onPressed: () async {
                          File imageFile =
                              await _camService.getImage(ImageSource.camera);
                          setState(() {
                            personImage = imageFile;
                          });
                          Navigator.pop(context);
                        },
                        text: 'Camera',
                        icon: Icon(
                          Icons.camera,
                          color: Colors.white,
                        ),
                        linearGradient: AppColors.linearGradient,
                      ),
                    ),
                    Container(
                      width: devWidth * 0.5,
                      child: KButton(
                        onPressed: () async {
                          File imageFile =
                              await _camService.getImage(ImageSource.gallery);
                          setState(() {
                            personImage = imageFile;
                          });
                          Navigator.pop(context);
                        },
                        text: 'Gallery',
                        icon: Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        linearGradient: AppColors.linearGradient,
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}