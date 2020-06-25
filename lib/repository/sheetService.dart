import 'package:e9pass_cs/models/sheetModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SheetService {
  final void Function(String) callBack;
  static const String URL = "https://script.google.com/macros/s/AKfycbxBEUdSQBv32y0pmthu7LT4THTKDoGGMaRHs3Z00cdRyHX8PwU/exec";
  static const String STATUS_SUCCESS = "SUCCESS";

  SheetService(this.callBack);

  void submitData(SheetModel sheetModel) async {
    try {
      await http.get(
        URL + sheetModel.toParams()
      ).then((value) => {
        callBack(convert.jsonDecode(value.body)['status'])
      });
    } catch (error) {
      print(error);
    }
  }
}


// https://script.google.com/macros/s/AKfycbxBEUdSQBv32y0pmthu7LT4THTKDoGGMaRHs3Z00cdRyHX8PwU/exec?name=Ishanga&appNo=2005252569&phNo=010792107014&arcNo=930714