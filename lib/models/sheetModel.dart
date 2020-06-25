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
  
  String toParams() => "?name=$name&appNo=$applicationNumber&phNo=$phoneNumber&arcNo=$arcNumber";
}