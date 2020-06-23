import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFactory {
  static pw.Document pdf;
  static PdfImage arcPdfImage;
  static PdfImage personPdfImage;


  static Future<pw.Document> getPdfFile(File arcImage, File personImage, String name, String arcNumber, String phoneNumber, String appNumber) async {
      
    pdf = pw.Document();
    var data = await rootBundle.load("assets/fonts/OpenSans-SemiBold.ttf");
    var myFont = pw.Font.ttf(data);
    if (arcImage != null) {
      arcPdfImage = PdfImage.file(
        pdf.document,
        bytes: arcImage.readAsBytesSync(),
      );
    } else {
      arcPdfImage = null;
    }
    if (personImage != null) {
      personPdfImage = PdfImage.file(
        pdf.document,
        bytes: personImage.readAsBytesSync(),
      );
    } else {
      personPdfImage = null;
    }

    name = name != null && name.length > 0 ? name : ' ';
    phoneNumber = phoneNumber != null && phoneNumber.length > 0 ? phoneNumber : ' ';
    appNumber = appNumber != null && appNumber.length > 0 ? appNumber : ' ';

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.fromLTRB(20, 10, 20, 10),
        build: (pw.Context context) {
          return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Header(
                    level: 1,
                    child: pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('E9pass Registration Document',
                                  style: pw.TextStyle(
                                      fontSize: 20,
                                      font: myFont,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Text('NAME : ' + name,
                                  style: pw.TextStyle(
                                      fontSize: 18,
                                      font: myFont,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Text('APP NO : ' + appNumber,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    font: myFont
                                  )),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('ARC NO : ' + arcNumber,
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: myFont
                                        )),
                                    pw.SizedBox(
                                      width: 20,
                                    ),
                                    pw.Text('PH : ' + phoneNumber,
                                        style: pw.TextStyle(
                                          fontSize: 16,
                                          font: myFont
                                        )),
                                  ]),
                            ]))),
                pw.Flexible(
                  child: arcPdfImage != null
                      ? pw.Container(
                          height: 320,
                          child: pw.Image(arcPdfImage, fit: pw.BoxFit.contain),
                        )
                      : pw.Container(),
                ),
                pw.SizedBox(height: 20),
                pw.Flexible(
                  child: personPdfImage != null
                      ? pw.Container(
                          height: 320,
                          child: pw.Image(personPdfImage, fit: pw.BoxFit.contain),
                        )
                      : pw.Container(),
                ),
                pw.SizedBox(height: 20),
              ]);
        }));
    return pdf;
  }
}