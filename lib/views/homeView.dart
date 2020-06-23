import 'dart:io';
import 'package:awesome_page_transitions/awesome_page_transitions.dart';
import 'package:e9pass_cs/repository/cameraService.dart';
import 'package:e9pass_cs/repository/fileService.dart';
import 'package:e9pass_cs/repository/pdfFactory.dart';
import 'package:e9pass_cs/views/pdfView.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:e9pass_cs/widget/flushbar.dart';
import 'package:e9pass_cs/widget/textInput.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  pw.Document pdfFile;
  File  arcImage;
  File  personImage;
  String  name;
  String  arcNumber;
  String  phoneNumber;
  String  appNumber;

  String errorText = ' ';
  bool saveButtonState = false;
  bool shareButtonState = false;
  ScrollController _scrollController;
  bool showTitleBar = false;

  bool validate(BuildContext context) {
    if (arcNumber != null && arcNumber.length > 5) {
      setState(() {
        errorText = '';
      });
      if (arcImage == null && personImage == null) {
        setState(() {
          errorText = 'At least one photo should be included!';
        });
        showFloatingFlushbar(context, errorText, false);
        return false;
      }
      return true;
    } else {
      setState(() {
        errorText = 'ARC nunmer should be at least 6 digit!';
      });
      showFloatingFlushbar(context, errorText, false);
      return false;
    }
  }

  Future<String> viewPdfFileFromMemory(BuildContext context) async {
    if (validate(context)) {
      pdfFile = await PdfFactory.getPdfFile(
        arcImage, 
        personImage, 
        name, 
        arcNumber, 
        phoneNumber, 
        appNumber
      );
      return await FileService.savePdfForView(pdfFile, arcNumber);
    }
    return null;
  }

  Future<bool> savePdfFileToPath(BuildContext context) async {
    if (validate(context)) {
      pdfFile = await PdfFactory.getPdfFile(
        arcImage, 
        personImage, 
        name, 
        arcNumber, 
        phoneNumber, 
        appNumber
      );
      String fileName = arcNumber;
      if (appNumber != null && appNumber.length > 0){
        fileName = '$arcNumber-$appNumber';
      }
      return await FileService.savePdfLocale(pdfFile, fileName);
    } else {
      setState(() {
        saveButtonState = false;
      });
      return false;
    }
  }

  Future<String> getQrResult() async {
    // String cameraScanResult = await scanner.scan();
    String cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.QR);
    if (cameraScanResult != null && cameraScanResult.length > 0) {
      return cameraScanResult;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(scroollListener);
    super.initState();
  }

  scroollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >
          _scrollController.position.maxScrollExtent * 0.2) {
        setState(() {
          showTitleBar = true;
        });
      } else {
        setState(() {
          showTitleBar = false;
        });
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            child: Container(
              width: devWidth,
              height: devHeight,
              color: AppColors.backgroundColor,
            ),
          ),
          ScrollConfiguration(
            behavior: ScrollBehavior()
              ..buildViewportChrome(context, null, AxisDirection.down),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        gradient: AppColors.linearGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )),
                    width: devWidth,
                    height: devHeight * 0.15,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('E9pass Register',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)))
                      ],
                    ),
                  ),
                  Container(
                    width: devWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('ARC / Passport Photo',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainTextColor))),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppColors.linearGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Clear',
                                style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
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
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)),
                    child: arcImage == null
                        ? Center(
                            child: Image.asset(
                            'assets/images/id-card.png',
                            fit: BoxFit.contain,
                          ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              arcImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: KButton(
                      text: 'ARC / Passport',
                      busy: false,
                      onPressed: () async {
                        File imageFile = await CamService.getImage();
                        setState(() {
                          arcImage = imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      linearGradient: LinearGradient(
                          colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                      navigate: false,
                    ),
                  ),
                  Container(
                    width: devWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Person\'s Verification Photo',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainTextColor))),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppColors.linearGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Clear',
                                style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
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
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)),
                    child: personImage == null
                        ? Center(
                            child: Image.asset(
                            'assets/images/login.png',
                            fit: BoxFit.contain,
                          ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              personImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: KButton(
                      text: 'Verification Photo',
                      busy: false,
                      onPressed: () async {
                        File imageFile = await CamService.getImage();
                        setState(() {
                          personImage = imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                      linearGradient: LinearGradient(
                          colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                      navigate: false,
                    ),
                  ),
                  Container(
                    width: devWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Application Number',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainTextColor))),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: AppColors.linearGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Clear',
                                style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ),
                          onTap: () {
                            setState(() {
                              appNumber = ' ';
                            });
                          },
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
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      appNumber != null ? appNumber : ' ',
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTextColor)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: KButton(
                      text: 'Scan Application Number',
                      busy: false,
                      onPressed: () async {
                        String result = await getQrResult();
                        if (result != null && result.length > 12) {
                          setState(() {
                            appNumber = result;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.scanner,
                        color: Colors.white,
                      ),
                      linearGradient: LinearGradient(
                          colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                      navigate: false,
                    ),
                  ),
                  Container(
                    width: devWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Personal Information',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainTextColor))),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: KTextInput(
                      lable: 'Name',
                      textInputType: TextInputType.text,
                      onSubmit: (text) {
                        setState(() {
                          name = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: KTextInput(
                      lable: 'ARC Number',
                      textInputType: TextInputType.number,
                      onSubmit: (text) {
                        setState(() {
                          arcNumber = text;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: KTextInput(
                      lable: 'Phone Number',
                      textInputType: TextInputType.number,
                      onSubmit: (text) {
                        setState(() {
                          phoneNumber = text;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  KButton(
                    text: 'View PDF',
                    busy: false,
                    onPressed: () async {
                      //On View
                      String path = await viewPdfFileFromMemory(context);
                      if (path != null && path.length > 0) {
                        Navigator.push(
                          context,
                          AwesomePageRoute(
                              transitionDuration: Duration(milliseconds: 300),
                              exitPage: widget,
                              enterPage: PdfView(
                                path: path,
                              ),
                              transition: ParallaxTransition()));
                      }
                    },
                    icon: Icon(
                      Icons.panorama_fish_eye,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                        colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                    navigate: false,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  KButton(
                    text: 'Save PDF & Photos',
                    busy: saveButtonState,
                    onPressed: () async {
                      //On Save
                      setState(() {
                        saveButtonState = true;
                      });
                      bool result = await savePdfFileToPath(context);
                      if (arcImage != null && result) {
                        String fileName = arcNumber;
                        if (appNumber != null && appNumber.length > 0){
                          fileName = '$arcNumber-$appNumber';
                        }
                        await FileService.saveImageToDownload(arcImage, '$fileName-ARC');
                      }
                      if (personImage != null && result) {
                        String fileName = arcNumber;
                        if (appNumber != null && appNumber.length > 0){
                          fileName = '$arcNumber-$appNumber';
                        }
                        await FileService.saveImageToDownload(personImage, '$fileName-Person');
                      }
                      await Future.delayed(Duration(seconds: 3));
                      if (result) {
                        showFloatingFlushbar(context, 'Files saved to the Download folder!', true);
                      }
                      setState(() {
                        saveButtonState = false;
                      });
                    },
                    icon: Icon(
                      Icons.file_download,
                      color: Colors.white,
                    ),
                    linearGradient: LinearGradient(
                        colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                    navigate: false,
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  // KButton(
                  //   text: 'Share to',
                  //   onPressed: () async {
                  //     String path = await viewPdfFileFromMemory(context);
                  //   },
                  //   icon: Icon(
                  //     Icons.share,
                  //     color: Colors.white,
                  //   ),
                  //   linearGradient: LinearGradient(
                  //       colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
                  //   navigate: false,
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.linearGradient,
                    ),
                    width: devWidth,
                    height: devHeight * 0.1,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Text('Developed by',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))),
                        Text('E9pay Remittance Sri Lanka',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: AnimatedOpacity(
              opacity: showTitleBar ? 1 : 0,
              duration: Duration(milliseconds: 200),
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: AppColors.linearGradient,
                ),
                width: devWidth,
                height: devHeight * 0.1,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('E9pass Register',
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
