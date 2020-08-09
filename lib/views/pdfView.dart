import 'dart:async';
import 'dart:io';

import 'package:e9pass_cs/repository/authService.dart';
import 'package:e9pass_cs/repository/driveService.dart';
import 'package:e9pass_cs/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:provider/provider.dart';

class PdfView extends StatefulWidget {
  final File file;
  PdfView({Key key, this.file}) : super(key: key);

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  DriveService driveService = DriveService();
  int pages = 0;
  bool isReady = false;
  String errorMessage = '';
  GlobalKey pdfKey = GlobalKey();
  bool isActive = true;
  double scale = 1.0;
  double top = 200.0;
  double initialLocalFocalPoint;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context);
    final Completer<PDFViewController> _controller = Completer<PDFViewController>();
    List<String> title = widget.file.path.split('/');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          "${title.last}",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.mainTextColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: PDFView(
              filePath: widget.file.path,
              key: pdfKey,
              fitEachPage: true,
              fitPolicy: FitPolicy.BOTH,
              dualPageMode: false,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              defaultPage: 8,
              pageSnap: true,
              backgroundColor: bgcolors.WHITE,
              onRender: (_pages) {
                print("OK RENDERED!!!!!");
                setState(() {
                  pages = _pages;
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                print(error.toString());
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
                print('$page: ${error.toString()}');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onPageChanged: (int page, int total) {
                print('page change: $page/$total');
              },
              onZoomChanged: (double zoom) {
                print("Zoom is now $zoom");
              }
            ),
          ),
        ],
      ),
      // floatingActionButton: FutureBuilder<PDFViewController>(
      //   future: _controller.future,
      //   builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
      //     if (snapshot.hasData) {
      //       return FloatingActionButton(
      //         onPressed: () async {
      //           if (authService.currentUser != null) {
      //             setState(() {
      //               loading = true;
      //             });
      //             await driveService.uploadFileToGoogleDrive(authService, widget.file);
      //             setState(() {
      //               loading = false;
      //             });
      //           }
      //         },
      //       );
      //     }
      //     return Container();
      //   },
      // ),
    );
  }
}