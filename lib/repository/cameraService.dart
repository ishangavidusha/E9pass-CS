import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CamService {
  ImagePicker picker = ImagePicker();

  Future<File> getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource, preferredCameraDevice: CameraDevice.rear);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
}