import 'dart:io';
import 'package:e9pass_cs/util/filrUtil.dart';
import 'package:flutter/foundation.dart';
import 'package:mime_type/mime_type.dart';
import 'package:permission_handler/permission_handler.dart';

class FileProvider extends ChangeNotifier {

  bool loading = false;
  List<FileSystemEntity> downloads = List();
  List<String> downloadTabs = List();

  getDownloads({bool shouldUpdate: true}) async {
    setLoading(true, shouldUpdate);
    if (await Permission.storage.request().isGranted) {
      downloadTabs.clear();
      downloads.clear();
      // downloadTabs.add("All");
      List<Directory> storages = await FileUtils.getStorageList();
      storages.forEach((dir) {
        if (Directory(dir.path + "E9pass CS/PDF Files").existsSync()) {
          List<FileSystemEntity> files = Directory(dir.path + "E9pass CS/PDF Files").listSync();
          files.forEach((file) {
            if (FileSystemEntity.isFileSync(file.path)) {
              if (mime(file.path) == 'application/pdf') {
                downloads.add(file);
              }
              downloadTabs.add(file.path.split("/")[file.path.split("/").length - 2]);
              downloadTabs = downloadTabs.toSet().toList();
              notifyListeners();
            }
          });
        }
      });
      downloads.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
      downloadTabs.add("All");
    }
    setLoading(false, shouldUpdate);
  }


  void setLoading(bool value, bool shouldUpdate) {
    loading = value;
    if (shouldUpdate) notifyListeners();
  }
}