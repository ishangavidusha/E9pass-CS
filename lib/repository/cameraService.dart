import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CamService {
  static ImagePicker picker = ImagePicker();

  static Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
    return File(pickedFile.path);
  }
}