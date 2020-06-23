import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CamService {
  static ImagePicker picker = ImagePicker();

  static Future<File> getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource, preferredCameraDevice: CameraDevice.rear);
    return File(pickedFile.path);
  }
}