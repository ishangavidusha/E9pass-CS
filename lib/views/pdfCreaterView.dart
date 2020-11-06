import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e9pass_cs/models/appSettings.dart';
import 'package:e9pass_cs/models/sheetModel.dart';
import 'package:e9pass_cs/repository/cameraService.dart';
import 'package:e9pass_cs/repository/fileService.dart';
import 'package:e9pass_cs/repository/pdfFactory.dart';
import 'package:e9pass_cs/repository/sheetService.dart';
import 'package:e9pass_cs/state/settingsProvider.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:tflite/tflite.dart';
import 'package:path/path.dart' as p;

class PDFCreaterView extends StatefulWidget {
  final bool statement;
  const PDFCreaterView({Key key, this.statement = false}) : super(key: key);
  @override
  _PDFCreaterViewState createState() => _PDFCreaterViewState();
}

class _PDFCreaterViewState extends State<PDFCreaterView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SheetService sheetService = SheetService();
  TextEditingController arcController;
  TextEditingController nameController;
  CamService _camService = CamService();
  PdfFactory _pdfFactory = PdfFactory();
  FileService _fileService = FileService();
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
  Size _imageSize;
  String recognizedText = "Loading ...";
  bool modelLoading = false;

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<List<dynamic>> classifyImage(File image) async {
    return await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
  }

  Future<Map<String, dynamic>> savePdfAndPhotos() async {
    try {
      print(widget.statement);
      if (widget.statement) {
        pdf = await _pdfFactory.getPdfFileWithStatement(arcImage, name, arcNumber, phoneNumber, appNumber);
      } else {
        pdf = await _pdfFactory.getPdfFile(arcImage, personImage, name, arcNumber, phoneNumber, appNumber);
      }
      String result = await _fileService.savePdfLocale(pdf, appNumber);
      if (result == null) {
        return {"state": false, "msg": 'Error occurred during Saving PDF'};
      }
      if (arcImage != null) {
        await _fileService.saveImageToDownload(arcImage, '$appNumber-ARC');
      }
      if (personImage != null) {
        await _fileService.saveImageToDownload(personImage, '$appNumber-Person');
      }
      return {"state": true, "msg": 'Done', 'path': result};
    } catch (error) {
      return {"state": false, "msg": error.toString()};
    }
  }

  Future<bool> sheetUpload(String sheetId) async {
    SheetModel sheetModel = SheetModel(
        name: name ?? 'null',
        applicationNumber: appNumber ?? 'null',
        arcNumber: arcNumber ?? 'null',
        phoneNumber: phoneNumber ?? 'null');
    try {
      return await sheetService.addPdfData(sheetModel, sheetId);
    } catch (error) {
      print(error);
    }
    return false;
  }

  void resetData() {
    setState(() {
      _formKey.currentState.reset();
      arcController.clear();
      nameController.clear();
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
    arcController = TextEditingController(text: null);
    nameController = TextEditingController(text: null);
    settingsProvider ??= Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.getSettings('settings');
    modelLoading = true;
    loadModel().then((value) {
      setState(() {
        print('Model Loaded!');
        modelLoading = false;
      });
    });
    super.initState();
  }


  @override
  void dispose() {
    Tflite.close();
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
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Color(0xFFFAFAFA),
                title: Text(
                  'E9pass PDF Creator',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainTextColor,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black,),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
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
                        onPressed: () async {
                          arcController.clear();
                          nameController.clear();
                          arcNumber = null;
                          name = null;
                          if (!modelLoading) {
                            bool isPassport = await getArcImage(devHeight, devWidth);
                            if (isPassport) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.WARNING,
                                animType: AnimType.BOTTOMSLIDE,
                                title: 'Warning',
                                desc: 'Look like the photo you took is passport! It\'s recommend to use ARC image for E9pass',
                                btnCancelText: 'Dismiss',
                                btnCancelOnPress: () {},
                                onDissmissCallback: () {})
                              ..show();
                            }
                          } else {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.INFO,
                              animType: AnimType.BOTTOMSLIDE,
                              title: 'Wait',
                              desc: 'TensorFlow Image Model is not loaded yet!',
                              btnOkText: 'OK',
                              btnOkOnPress: () {},
                              onDissmissCallback: () {})
                            ..show();
                          }
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
                    !widget.statement ? Container(
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
                    ) : Container(),
                    !widget.statement ? Container(
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
                    ) : Container(),
                    !widget.statement ? Padding(
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
                    ) : Container(),
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
                          // setState(() {
                          //   appNumber = '201024-2428-0881';
                          // });
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
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: nameInput(),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: arcNumberInput(),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                  appSettings = await settingsProvider.getSettings('settings');
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
                                      btnOkText: 'Share',
                                      btnOkOnPress: () {
                                        String path = pdfResult['path'];
                                        Share.shareFiles([path], text: p.basename(path).split('.').first, subject: 'E9PASS PDF');
                                        resetData();
                                      },
                                      btnCancelText: 'Clear',
                                      btnCancelOnPress: () {
                                        resetData();
                                      },
                                      onDissmissCallback: () {}
                                    )..show();
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
                      height: devHeight * 0.1,
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
            ],
          ),
          saving ? Positioned(
            bottom: 0,
            width: devWidth,
            child: Container(
              height: devHeight * 0.3,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFFAFAFA).withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 6.0,
                    sigmaY: 6.0,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Uploading...',
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }

  Widget nameInput() {
    return TextFormField(
      controller: nameController,
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
      onSaved: (newValue) {
        setState(() {
          name = newValue;
        });
      },
    );
  }

  Widget arcNumberInput() {
    return TextFormField(
      controller: arcController,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'ARC Number',
        hintText: '920802-XXXXXXX',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
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
      onSaved: (newValue) {
        setState(() {
          arcNumber = newValue;
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
      onSaved: (newValue) {
        setState(() {
          phoneNumber = newValue;
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

  Future<void> getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();
    // Fetching image from path
    final Image image = Image.file(imageFile);

    // Retrieving its size
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  void initializeVision(File imageToRead) async {
    // if (imageToRead != null) {
    //   await getImageSize(imageToRead);
    // }
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageToRead);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    String arcNumPattern = r"[0-9][0-9][0-1][0-9][0-3][0-9]-[5-6][0-9]{6}";
    String namePattern = r"[a-zA-Z -]+";
    String arcRemovePattern = r"ALIEN|REGISTRATION|CARD|KOR";
    RegExp regExArc = RegExp(arcNumPattern);
    RegExp regExName = RegExp(namePattern);
    RegExp regExArcRemove = RegExp(arcRemovePattern);
    String visionArcNumber;
    String fullName;
    String corectedFullName = '';
    List<String> nameList = List();
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        // Checking if the line contains an email address
        if (regExArc.hasMatch(line.text)) {
          RegExpMatch match = regExArc.firstMatch(line.text);
          // print(match.group(0));
          visionArcNumber = match.group(0);
        }
        if (regExName.hasMatch(line.text) &&
            !regExArcRemove.hasMatch(line.text)) {
          RegExpMatch match = regExName.firstMatch(line.text);
          nameList.add(match.group(0));
        }
      }
    }
    if (nameList.length >= 4) {
      for (String name in nameList) {
        if (name.length > 12) {
          int index = nameList.indexOf(name);
          String lastElement = nameList[index]
              .substring(nameList[index].length - 1, nameList[index].length);
          if (lastElement == '-') {
            fullName =
                nameList[index].substring(0, nameList[index].length - 1) +
                    nameList[index + 1];
          } else {
            fullName = nameList[index] + ' ' + nameList[index + 1];
          }
          break;
        }
      }
      if (fullName != null) {
        for (String i in fullName.split('')) {
          // print(i);
          if (i == 'l') {
            corectedFullName += 'I';
          } else {
            corectedFullName += i;
          }
        }
      }
    }
    if (this.mounted) {
      setState(() {
        arcController.text = visionArcNumber;
        arcNumber = visionArcNumber;
        nameController.text =
            corectedFullName != null && corectedFullName.length > 0
                ? corectedFullName
                : null;
        name = corectedFullName != null && corectedFullName.length > 0
            ? corectedFullName
            : null;
      });
      textRecognizer.close();
    }
  }

  Future<bool> getArcImage(double devHeight, double devWidth) {
    bool isPassport = false;
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: new Container(
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
                            File imageFile = await _camService.getImage(
                              ImageSource.camera,
                            );
                            if (imageFile != null) {
                              List<dynamic> result = await classifyImage(imageFile);
                              if (result != null && result[0]["label"] == '1 ID Card') {
                                initializeVision(imageFile);
                              } else {
                                isPassport = true;
                              }
                            }
                            setState(() {
                              arcImage = imageFile;
                            });
                            Navigator.pop(context, isPassport);
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
                            File imageFile = await _camService.getImage(
                              ImageSource.gallery,
                            );
                            if (imageFile != null) {
                              List<dynamic> result = await classifyImage(imageFile);
                              if (result != null && result[0]["label"] == '1 ID Card') {
                                initializeVision(imageFile);
                              } else {
                                isPassport = true;
                              }
                            }
                            setState(() {
                              arcImage = imageFile;
                            });
                            Navigator.pop(context, isPassport);
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
            ),
          );
        });
  }

  void getPersonImage(double devHeight, double devWidth) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: new Container(
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
            ),
          );
        });
  }
}