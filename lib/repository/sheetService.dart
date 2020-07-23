import 'package:e9pass_cs/models/sheetModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SheetService {

  Future<String> submitData(SheetModel sheetModel, String sheetUrl) async {
    try {
      http.Response response = await http.get(sheetUrl + sheetModel.toParams());
      return convert.jsonDecode(response.body)['status'];
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }
}