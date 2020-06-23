import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PdfView extends StatefulWidget {
  final String path;

  const PdfView({Key key, this.path}) : super(key: key);
  
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PDFViewerScaffold(path: widget.path),
      ],
    );
  }
}