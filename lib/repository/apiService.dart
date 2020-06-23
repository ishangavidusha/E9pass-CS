import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static final url = 'http://192.168.50.85:3000/upload';

  static Future<ResResult> uploadImage(filename) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('pdf', filename));
      var res = await request.send().timeout(Duration(seconds: 2));
      if (res.statusCode == 200) {
        return ResResult(
          status: res.statusCode,
          msg: res.reasonPhrase
        );
      }
    } on TimeoutException catch (error) {
      print(error);
      return ResResult(
        status: 500,
        msg: error.toString()
      );
    } on SocketException catch (error) {
      print(error);
      return ResResult(
        status: 500,
        msg: error.toString()
      );
    }
    return ResResult(
      status: 500,
      msg: 'Error'
    );
  }
}

class ResResult {
  int status;
  String msg;

  ResResult({
    this.status,
    this.msg
  });
}