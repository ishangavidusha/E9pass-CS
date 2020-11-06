import 'dart:io';
import 'package:image/image.dart' as im;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';

List<int> resizeImage(File imageFile) {
  im.Image tempImage = im.decodeImage(imageFile.readAsBytesSync());
  tempImage = im.bakeOrientation(tempImage);
  tempImage = im.copyResize(tempImage, width: 800);
  return im.encodeJpg(tempImage);
}

class PdfFactory {
  pw.Document pdf;
  PdfImage arcPdfImage;
  PdfImage personPdfImage;

  Future<pw.Document> getPdfFileWithStatement(File arcImage, String name, String arcNumber, String phoneNumber, String appNumber) async {
    pdf = pw.Document();
    var data = await rootBundle.load("assets/fonts/OpenSans-SemiBold.ttf");
    var kFontData = await rootBundle.load("assets/fonts/GothicA1-Medium.ttf");
    var myFont = pw.Font.ttf(data);
    var kFont = pw.Font.ttf(kFontData);
    if (arcImage != null) {
      List<int> imageBytes = await compute(resizeImage, arcImage);
      arcPdfImage = PdfImage.file(
        pdf.document,
        bytes: imageBytes,
      );
    } else {
      arcPdfImage = null;
    }
    var fullDate = appNumber.split('-').first;
    var year = fullDate.substring(0, 2);
    var month = fullDate.substring(2, 4);
    var date = fullDate.substring(4, 6);
    name = name != null && name.length > 0 ? name : ' ';
    phoneNumber = phoneNumber != null && phoneNumber.length > 0 ? phoneNumber : ' ';
    appNumber = appNumber != null && appNumber.length > 0 ? appNumber : ' ';
    arcNumber = arcNumber != null && arcNumber.length > 0 ? arcNumber : ' ';
    double devHeight = PdfPageFormat.a4.availableHeight;
    double devWidth = PdfPageFormat.a4.availableWidth;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: devWidth,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('E9pass Registration Document',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#003366'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Text('NAME : $name',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1C1C1C'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Text('APPLICATION NO : $appNumber',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1C1C1C'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('ARC NO : $arcNumber',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: myFont,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1C1C1C'),
                          ),
                        ),
                        pw.Text('PH : $phoneNumber',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: myFont,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1C1C1C'),
                          ),
                        ),
                      ]
                    ),
                    pw.Divider(
                      thickness: 2.0,
                      color: PdfColor.fromHex('#1C1C1C'),
                    ),
                  ]
                ),
              ),
              pw.Container(
                height: devHeight * 0.4,
                width: devWidth,
                child: arcPdfImage != null ? pw.Image(arcPdfImage, fit: pw.BoxFit.contain) : pw.Container(),
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                width: devWidth,
                padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                    bottom: true,
                    top: true,
                    left: true,
                    right: true,
                    color: PdfColors.black,
                  )
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      '동의서',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: kFont,
                      )
                    ),
                    pw.SizedBox(
                      height: 20,
                    ),
                    pw.Text(
                      '상기 본인은 E9PASS 가입 시 발급된 공인 인증서(개인범용)의 이용과 관련하여 해외, 국내 송금 목적의 ㈜이나인페이 즉시 출금 서비스(Auto debit) 사용을 위한 금융결제원 본인인증(CID)용으로 제한하는 ㈜이나인페이 목적에 동의하며, 금융결제원 본인 인증 절차 통과 후 각종 금융사고(보이스피싱 및 금융범죄) 예방차원으로 E9PASS(KICA) 폐기에 대하여 동의합니다.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: kFont,
                        lineSpacing: 3,
                        letterSpacing: 1.2,
                        fontWeight: pw.FontWeight.normal
                      ),
                      textAlign: pw.TextAlign.justify
                    ),
                    pw.SizedBox(
                      height: 15,
                    ),
                    pw.Text(
                      '20$year 년  $month 월  $date 일',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: kFont,
                      )
                    ),
                    pw.SizedBox(
                      height: 25,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '이름 : ',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: kFont,
                          )
                        ),
                        pw.SizedBox(
                          width: devWidth * 0.3,
                          child: pw.Flexible(
                            child: pw.Text(
                              '$name',
                              style: pw.TextStyle(
                                fontSize: 10,
                                font: kFont,
                                letterSpacing: 1.0,
                                lineSpacing: 1.0,
                              ),
                              softWrap: true,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        pw.SizedBox(
                          width: 10
                        ),
                        pw.Text(
                          '인 :           ',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: kFont,
                          )
                        ),
                      ]
                    )
                  ]
                ),
              ),
            ]
          );
        },
      ),
    );
    return pdf;
  }


  Future<pw.Document> getPdfFile(File arcImage, File personImage, String name, String arcNumber, String phoneNumber, String appNumber) async {
      
    pdf = pw.Document();
    var data = await rootBundle.load("assets/fonts/OpenSans-SemiBold.ttf");
    var myFont = pw.Font.ttf(data);
    if (arcImage != null) {
      List<int> imageBytes = await compute(resizeImage, arcImage);
      arcPdfImage = PdfImage.file(
        pdf.document,
        bytes: imageBytes,
      );
    } else {
      arcPdfImage = null;
    }
    if (personImage != null) {
      List<int> imageBytes = await compute(resizeImage, arcImage);
      personPdfImage = PdfImage.file(
        pdf.document,
        bytes: imageBytes,
      );
    } else {
      personPdfImage = null;
    }

    name = name != null && name.length > 0 ? name : ' ';
    phoneNumber = phoneNumber != null && phoneNumber.length > 0 ? phoneNumber : ' ';
    appNumber = appNumber != null && appNumber.length > 0 ? appNumber : ' ';
    arcNumber = arcNumber != null && arcNumber.length > 0 ? arcNumber : ' ';
    double devHeight = PdfPageFormat.a4.availableHeight;
    double devWidth = PdfPageFormat.a4.availableWidth;
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: devWidth,
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('E9pass Registration Document',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#003366'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Text('NAME : $name',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1C1C1C'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Text('APPLICATION NO : $appNumber',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: myFont,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1C1C1C'),
                      ),
                    ),
                    pw.SizedBox(
                      height: 5,
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('ARC NO : $arcNumber',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: myFont,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1C1C1C'),
                          ),
                        ),
                        pw.Text('PH : $phoneNumber',
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: myFont,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1C1C1C'),
                          ),
                        ),
                      ]
                    ),
                    pw.Divider(
                      thickness: 2.0,
                      color: PdfColor.fromHex('#1C1C1C'),
                    ),
                  ]
                ),
              ),
              pw.Container(
                height: devHeight * 0.4,
                width: devWidth,
                child: arcPdfImage != null ? pw.Image(arcPdfImage, fit: pw.BoxFit.contain) : pw.Container(),
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                height: devHeight * 0.4,
                width: devWidth,
                child: personPdfImage != null ? pw.Image(personPdfImage, fit: pw.BoxFit.contain) : pw.Container(),
              ),
            ]
          );
        },
      ),
    );
    return pdf;
  }
}