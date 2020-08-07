import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfView extends StatefulWidget {
  final String path;
  PdfView({Key key, this.path}) : super(key: key);

  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PDF().fromPath(widget.path),
    );
  }
}