class SheetModel {
  String name;
  String applicationNumber;
  String phoneNumber;
  String arcNumber;

  SheetModel({
    this.name,
    this.applicationNumber,
    this.phoneNumber,
    this.arcNumber
  });
  
  String toParams() => "?name=$name&appNumber=$applicationNumber&phoneNumber=$phoneNumber&arcNumber=$arcNumber";
}