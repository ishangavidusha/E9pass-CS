
import 'dart:ui';
import 'package:e9pass_cs/repository/sheetService.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:e9pass_cs/widget/customButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class E9passNumberUpload extends StatefulWidget {
  final String sheetId;

  const E9passNumberUpload({Key key, this.sheetId}) : super(key: key);
  @override
  _E9passNumberUploadState createState() => _E9passNumberUploadState();
}

class _E9passNumberUploadState extends State<E9passNumberUpload> {
  ScrollController _scrollController;
  SheetService sheetService = SheetService();
  String appNumber;
  bool sheetButtonState = false;
  bool found = true;
  bool update = true;
  String msg = '';

  Future<String> getQrResult() async {
    // String cameraScanResult = await scanner.scan();
    String cameraScanResult = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
    if (cameraScanResult != null && cameraScanResult.length > 2) {
      return cameraScanResult;
    } else {
      return null;
    }
  }

  chack(String number) async {
    setState(() {
      appNumber = number;
      sheetButtonState = true;
    });
    // Sheet upload call
    Map<String, dynamic> result = await sheetService.chackApplicationNumber(appNumber, widget.sheetId);
    if(result != null) {
      setState(() {
        found = result['found'];
        update = result['update'];
        msg = result['msg'].toString();
      });
    }
    setState(() {
      sheetButtonState = false;
    });
  }


  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
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
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  width: devWidth,
                  height: devHeight * 0.15,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E9pass Application Number',
                            style: GoogleFonts.roboto(
                              color: Color(0xFF313233),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Check from Google Sheet',
                            style: GoogleFonts.roboto(
                              color: Color(0xFF313233),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: devWidth,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Application Number',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 16,
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
                          ),
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
                            appNumber = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 60,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainTextColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height:40,
                ),
                Container(
                  width: devWidth * 0.8,
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10)),
                  child: appNumber != null ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        found ? 'Application number found' : 'Application number not found',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: found ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        update ? 'Successfully Updated' : 'Failed to update',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: update ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Divider(),
                      Text(
                        msg,
                        style: GoogleFonts.pacifico(
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainTextColor,
                          ),
                        ),
                      ),
                    ],
                  ) : Container(
                    child: Text(
                      'Ready For Scan',
                      style: GoogleFonts.pacifico(
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: devHeight * 0.08,
            width: devWidth,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: KButton(
                text: 'Check',
                onPressed: () async {
                  getQrResult().then((value) => {
                    if (value != null || value.length > 2) {
                      chack(value)
                    }
                  });
                },
                icon: Icon(
                  Icons.find_in_page,
                  color: Colors.white,
                ),
                linearGradient: LinearGradient(
                    colors: [Color(0xFF1D73FF), Color(0xFF438AFE)]),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            width: devWidth,
            child: sheetButtonState ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Center(child: CircularProgressIndicator()),
            ) : Container()
          ),
        ],
      ),
    );
  }
}