import 'package:cloud_firestore/cloud_firestore.dart';

class AppData {
  String country;
  DateTime lastUpdate;
  String sheetUrl;

  AppData({this.country,this.lastUpdate, this.sheetUrl});

  factory AppData.fromJson(Map<dynamic, dynamic> json) => _appDataFromJson(json);

  Map<String, dynamic> toJson() => _appDataToJson(this);
  @override
  String toString() => "AppData<$country>";
}


AppData _appDataFromJson(Map<dynamic, dynamic> json) {
  return AppData(
    country: json['country'] as String,
    lastUpdate: json['lastUpdate'] == null ? null : (json['lastUpdate'] as Timestamp).toDate(),
    sheetUrl: json['sheetUrl'] as String,
  );
}

Map<String, dynamic> _appDataToJson(AppData instance) =>
  <String, dynamic> {
    'country': instance.country,
    'lastUpdate': instance.lastUpdate,
    'sheetUrl': instance.sheetUrl,
  };