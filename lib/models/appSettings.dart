class AppSettings {
  String sheetUrl;
  bool upload;
  String country;

  AppSettings({this.sheetUrl, this.upload, this.country});

  AppSettings.fromJson(Map<String, dynamic> json) {
    sheetUrl = json['sheetUrl'];
    upload = json['upload'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sheetUrl'] = this.sheetUrl;
    data['upload'] = this.upload;
    data['country'] = this.country;
    return data;
  }
}