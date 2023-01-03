class FulfillmentInformation{
  String orderId;
  String date;
  String userId;
  String fromLocation;
  String skuLine;
  String skuBrand;
  String skuModel;
  String skuGrade;
  Map<dynamic,dynamic> packageList;

  FulfillmentInformation({
    required this.orderId,
    required this.date,
    required this.userId,
    required this.fromLocation,
    required this.skuLine,
    required this.skuBrand,
    required this.skuModel,
    required this.skuGrade,
    required this.packageList,
  });
}
