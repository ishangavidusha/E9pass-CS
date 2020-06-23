import 'dart:io';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class ShareService {
  static Future<bool> shareToApp(String pdfFilePath, File arcImage, File personImage, String arcNumber) async {
    File file = File(pdfFilePath);
    try {
      Uint8List pdfBytes = file.readAsBytesSync();
      ByteData pdfFile = ByteData.view(pdfBytes.buffer);
      Uint8List arcBytes = file.readAsBytesSync();
      ByteData arcFile = ByteData.view(arcBytes.buffer);
      Uint8List perBytes = file.readAsBytesSync();
      ByteData perFile = ByteData.view(perBytes.buffer);
      await Share.files(
        'E9pass',
        {
            'e9pass.pdf': pdfFile.buffer.asUint8List(),
            'arcImage.jpg': arcFile.buffer.asUint8List(),
            'personImage.jpg': perFile != null ? perFile.buffer.asUint8List() : null,
        },
        '*/*',
        text: '$arcNumber'
      );
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}