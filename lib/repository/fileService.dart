import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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
      if (await Permission.storage.request().isGranted) {
        await ImageGallerySaver.saveImage(imageFile.readAsBytesSync(), name: fileName);
      }
      return true;
    } catch (error) {
      throw error;
    }
  }

  Future<String> savePdfLocale(pw.Document pdfFile, String fileName) async {
    try {
      if (await Permission.storage.request().isGranted) {
        String appPath = await _getPath();
        String pdfPath = '$appPath/PDF Files';
        File file = File("$pdfPath/$fileName.pdf");
        if (!await Directory(pdfPath).exists()) {
          await Directory(pdfPath).create(recursive: true); 
        }
        file = await file.writeAsBytes(pdfFile.save());
        return file.path;
      }
      return null;
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
    return ExtStorage.getExternalStoragePublicDirectory('E9pass CS');
  }
}
