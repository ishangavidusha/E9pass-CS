import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {

  static Future<bool> saveImageToDownload(File imageFile, String fileName) async {
    try {
      String folderPath = await _getPath();
      File file = File("$folderPath/$fileName.jpg");
      if (await Permission.storage.request().isGranted) {
        file.writeAsBytesSync(imageFile.readAsBytesSync());
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  static Future<bool> savePdfLocale(pw.Document pdfFile, String fileName) async {
    try {
      String pdfPath = await _getPath();
      File file = File("$pdfPath/$fileName.pdf");
      if (await Permission.storage.request().isGranted) {
        file.writeAsBytesSync(pdfFile.save());
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  static Future<String> savePdfForView(pw.Document pdfFile, String fileName) async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String docPath = documentDirectory.path;
    File file = File("$docPath/$fileName.pdf");
    file.writeAsBytesSync(pdfFile.save());
    return "$docPath/$fileName.pdf";
  }

  static Future<String> _getPath() {
    return ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
  }
}