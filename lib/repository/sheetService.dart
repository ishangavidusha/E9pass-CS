import 'package:e9pass_cs/models/sheetModel.dart';
import 'package:gsheets/gsheets.dart';


// google auth credentials
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "e9pass-cs",
  "private_key_id": "11e14f17641b628c3903e078c5da751cf805e450",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDzVg1hfDItsLkL\nP00G5y68xZJWj6bxg5OVL1YB1UHa2HCF8zpLB329vPMBiK9CTy1lWT2/OmkftakS\n8krvOUaQBDXLwF8rtzp7Gcbf9M1nLprVfJvIrNEfhKyA4+Uvgzbk6lDXG8ybj869\nTgE9iCc/0CDTb4T28RFi+Za0TGfoM2C/kjPrkod4GY9Q58DijLJ9IjuwdrV69omj\nIKasanmKM13I1TMcDLI2bpz/8dGapWlhpCTuTTiMjSjh672kuDIv6l2OoT/QbVaY\nE5TADySALwicJWZj8//muCvfQseMTboWsMXT/J1bjJLnxpmkqaETSR16AamDLJao\nHDo3QYmBAgMBAAECggEAFqvbz0tc+XjPpMafDJeZeSkHO11i9nmF1I52evE9k4A6\n65//vGHUS0tBcNElUw5BcoHgCOMOTFAGkqdUZ/l0I5Lg2DzyIQaPQkzihJcwU/65\nmk5jzUycp00bLV8OSWD2Slmycng6lfvODUEpSGxZC87+X/Sx9Lf9ILWUXvQHclC4\nmxpp12Q+lXJGJDWG7Krd7NOf5KdL2HoJj6yucau99Yk4jaao/993eDIGB+rHb1s2\n/ThgHUw8t799sY5E/TMp8FHIrXYfdPyQ5MpkjR+hRcrVHrIJeuco9Idv2QPBktTj\nBcQKEQj7PGNtMWpsgX3IlnyWr8FuP1N1bftc/xzaiQKBgQD/2heB1KgdIYvTrac5\nlfPjIWJB3Ej2KN77VtzcHPXvrVhLFCiHupJK6q6us1xYridGACsapVeW1T9aboj1\nbZ7XiUY/gi0wysY5mQuC+EPwUXVB14Hg/IUUnVwP+hPSkcqXjeMvLQmVqO7ZnRzO\nqHH7hF9eIXJc9rDGwlD7ZBJ5swKBgQDzehsmEJ+JYFQPYrMwwX7KggFZqPHwophE\nWkIGf+9QM+2vOIXRmEw6iHrTze74NJQCUykoO90lcrRMBF4QRCxss2Xw98rOk8fn\nhpDxhIlygjzh9Lik+hBBlVAvqlYB3fu4Wbe1zM51kfhNK9Jha08fN1KDYJrJX2I0\noJU0J+Ft+wKBgF2twQWsk5F3AveSkbQoD5COXKe4vI5FEL/+YgfGItaLJdT3oI9x\n5LbBjwwwaBOgUIj07tNmztdPZU77QfJ7HLnWbX47b8h5tnLIcsqVlGqdqM1e1xNF\n4oRVyauf6TokX4V2UkSnvOarYCkVucKBMprhMPoKTRF00e00oOorDgi5AoGAbXsB\njCs7YY10Hvr1sj2/opW0v7lNGTQzncCsIboTRRAkl36mBaoi1Msb1/OouekCiM0W\nG6ZXeYhLdEceeNf+1d4RP7pccmlXIU+MC13aZCgV8lCVWnGrL6JRTS2dwPctQibt\niY0PZSR+70x+LBoRmOrKapLc5yHBygJPNQWdw1MCgYEA9VBmkUYhZHsSfcnX2wTX\ngLZHTvT4hNrGpZ8rOnlSOAof9ve5UPVSiG0ajDafKYKa4n8VVu7N8bALpfh4qgb6\nR5vWDogBHPUaxMrRC1Ir8cJLDSUpEG5NaZb1T22fihIYkhUzqWFRT8nw7cLJN5OE\n86lv/sd9b4tsXVDIlB/aFWY=\n-----END PRIVATE KEY-----\n",
  "client_email": "ishanga@e9pass-cs.iam.gserviceaccount.com",
  "client_id": "105134107086535559312",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/ishanga%40e9pass-cs.iam.gserviceaccount.com"
}
''';

class SheetService {
  GSheets gsheets = GSheets(_credentials);
  Spreadsheet spreadsheet;
  Spreadsheet pdfDataspreadsheet;

  Future<Map<String, dynamic>> chackApplicationNumber(String applicationNumber, String sheetId) async {
    try {
      spreadsheet ??= await gsheets.spreadsheet(sheetId);
      Worksheet worksheet = spreadsheet.worksheetByIndex(0);
      List data = await worksheet.values.allRows();
      int found =  data.indexWhere((element) => element[0] == applicationNumber);
      if (found != -1) {
        if (data[found][1] == 'true') {
          return {'found': true, 'update' : false, 'msg' : 'This Number Already Checked'};
        } else {
          bool result = await worksheet.values.insertValue(true, column: 2, row: found + 1);
          if (result) {
            return {'found': true, 'update' : true, 'msg' : 'Found & Checked'};
          } else {
            return {'found': true, 'update' : false, 'msg' : 'Found But Faild Checked'};
          }
        }
      } else {
        print('Not Found');
        return {'found': false, 'update' : false, 'msg' : 'Not Found!'};
      }
    } catch (e) {
      print(e);
      return {'found': false, 'update' : false, 'msg' : e};
    }
  }

  Future<bool> addPdfData(SheetModel sheetModel, String sheetId) async {
    try {
      pdfDataspreadsheet ??= await gsheets.spreadsheet(sheetId);
      Worksheet worksheet = pdfDataspreadsheet.worksheetByIndex(0);
      bool result = await worksheet.values.appendRow([
        sheetModel.applicationNumber,
        sheetModel.name,
        sheetModel.arcNumber,
        sheetModel.phoneNumber
      ]);
      print(result);
      return result;
    } catch (e) {
      print(e);
      return false;
    }
  }
}