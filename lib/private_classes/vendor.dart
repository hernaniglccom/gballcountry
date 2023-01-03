class VendorData{
  String vendorId;
  String vendorName;
  VendorData({required this.vendorId, required this.vendorName});
  @override
  String toString() => "vendorName: $vendorName, invoiceId: $vendorId";
}

class VendorInformation{
  String vendorName;
  VendorInformation({required this.vendorName});
  @override
  String toString(){
    var returnText = 'vendorName: $vendorName';
    return returnText;
  }

}