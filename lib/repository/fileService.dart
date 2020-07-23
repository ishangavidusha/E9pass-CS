import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  Future<bool> clearCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> saveImageToDownload(File imageFile, String fileName) async {
    try {
      String folderPath = await _getPath();
      File file = File("$folderPath/$fileName.jpg");
      if (await Permission.storage.request().isGranted) {
        file.writeAsBytesSync(imageFile.readAsBytesSync());
      }
      return true;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> savePdfLocale(pw.Document pdfFile, String fileName) async {
    try {
      String pdfPath = await _getPath();
      File file = File("$pdfPath/$fileName.pdf");
      if (await Permission.storage.request().isGranted) {
        file.writeAsBytesSync(pdfFile.save());
      }
      return true;
    } catch (error) {
      throw error;
    }
  }

  Future<String> savePdfForView(pw.Document pdfFile, String fileName) async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String docPath = documentDirectory.path;
    File file = File("$docPath/$fileName.pdf");
    file.writeAsBytesSync(pdfFile.save());
    return "$docPath/$fileName.pdf";
  }

  Future<String> _getPath() {
    return ExtStorage.getExternalStoragePublicDirectory(
      ExtStorage.DIRECTORY_DOWNLOADS,
    );
  }
}
