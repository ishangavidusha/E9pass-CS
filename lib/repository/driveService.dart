import 'dart:io';
import 'package:e9pass_cs/models/drivrResponse.dart';
import 'package:e9pass_cs/repository/authService.dart';
import 'package:path/path.dart' as path;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as googleDrive;
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) => super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) => super.head(url, headers: headers..addAll(_headers));

}

class DriveService {
  googleDrive.DriveApi drive;

  Future init(AuthService authService) async {
    try {
      GoogleSignInAccount googleSignInAccount = await authService.googleSignIn.signInSilently();
      GoogleHttpClient client = GoogleHttpClient(await googleSignInAccount.authHeaders);
      drive = googleDrive.DriveApi(client);
    } catch (error) {
      throw error;
    }
  }

  Future<googleDrive.FileList> searchFolderInDrive(String name) async {
    try {
      googleDrive.FileList response = await drive.files.list(
        q: "name = '$name' and mimeType = 'application/vnd.google-apps.folder' and trashed=false",
        pageSize: 100,
        spaces: 'drive',
      );
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<googleDrive.FileList> searchFileInDrive(String folderId, String fileName) async {
    try {
      googleDrive.FileList response = await drive.files.list(
        q: "parents in '$folderId' and name = '$fileName' and mimeType = 'application/pdf' and trashed=false",
        pageSize: 100,
        spaces: 'drive',
      );
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<googleDrive.FileList> searchAllFiles(String folderId, String nextPageToken) async {
    try {
      googleDrive.FileList response = await drive.files.list(
        q: "parents in '$folderId' and mimeType = 'application/pdf' and trashed=false",
        pageSize: 100,
        spaces: 'drive',
        pageToken: nextPageToken,
      );
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<String> checkFolder() async {
    String id;
    try {
      googleDrive.FileList response = await searchFolderInDrive('E9pass PDF');
      if (response.files.length > 0){
        response.files.forEach((googleDrive.File file) {
          id = file.id;
        });
      } else {
        googleDrive.File folderToCreate = googleDrive.File();
        folderToCreate.mimeType = 'application/vnd.google-apps.folder';
        folderToCreate.name = 'E9pass PDF';
        googleDrive.File response = await drive.files.create(
          folderToCreate,
        );
        id = response.id;
      }
    } catch (error) {
      throw error;
    }
    return id;
  }

  Future<bool> checkFileInFolder(String folderId, String fileName) async {
    bool result;
    try {
      googleDrive.FileList response = await searchFileInDrive(folderId, fileName);
      if (response.files.length > 0){
        response.files.forEach((googleDrive.File file) {
          result = true;
        });
      } else {
        result = false;
      }
    } catch (error) {
      throw error;
    }
    return result;
  }

  Future<List<String>> getAllPdfs() async {
    try {
      String folderId = await checkFolder();
      String token;
      List<String> fileList = [];
      googleDrive.FileList response = await searchAllFiles(folderId, token);
      response.files.forEach((googleDrive.File file) {
        fileList.add(file.name);
      });
      token = response.nextPageToken;
      while (token != null) {
        googleDrive.FileList response = await searchAllFiles(folderId, token);
        response.files.forEach((googleDrive.File file) {
          fileList.add(file.name);
        });
        token = response.nextPageToken;
      }
      return fileList;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  Future<GoogleDriveUploadResponse> uploadFileToGoogleDrive(File file) async {
    try {
      String folderId = await checkFolder();
      bool result = await checkFileInFolder(folderId, path.basename(file.absolute.path));
      if (!result) {
        googleDrive.File fileToUpload = googleDrive.File();
        fileToUpload.parents = [folderId];
        fileToUpload.name = path.basename(file.absolute.path);
        googleDrive.File response = await drive.files.create(
          fileToUpload,
          uploadMedia: googleDrive.Media(file.openRead(), file.lengthSync()),
        );
        GoogleDriveUploadResponse myResponse = GoogleDriveUploadResponse(result: true, message: 'Done');
        return myResponse;
      } else {
        GoogleDriveUploadResponse myResponse = GoogleDriveUploadResponse(result: false, message: 'File already exists!');
        return myResponse;
      }
    } catch (error) {
      throw error;
    }
  }
}
