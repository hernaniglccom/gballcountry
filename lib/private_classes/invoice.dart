class InvoiceData{
  String invoiceId;
  String vendorName;
  String invoiceName;
  int invoiceSerialNumber;
  List<Map<String, dynamic>> invoiceContent;
  InvoiceData({required this.invoiceId, required this.vendorName, required this.invoiceName, required this.invoiceSerialNumber, required this.invoiceContent});
  @override
  String toString() => "vendorName: $vendorName, invoiceId: $invoiceId, invoiceName: $invoiceName, invoiceSerialNumber: $invoiceSerialNumber, invoiceContent: $invoiceContent";
}

class InvoiceInformation{
  String vendorName;
  String invoiceName;
  int invoiceSerialNumber;
  List<dynamic> invoiceCurrentContent;
  List<dynamic> invoiceOriginalContent;
  InvoiceInformation({required this.vendorName,  required this.invoiceName, required this.invoiceSerialNumber, required this.invoiceCurrentContent, required this.invoiceOriginalContent});
  @override
  String toString(){
    var returnText = 'vendorName: $vendorName, invoiceName: $invoiceName, invoiceSerialNumber: $invoiceSerialNumber; \n Contents: ';
    for(var i=0;i<invoiceCurrentContent.length;i+=1){
      returnText = '$returnText \n - ${invoiceCurrentContent[i]['Quantity']} ${invoiceCurrentContent[i]['Line']} ${invoiceCurrentContent[i]['Brand']} ${invoiceCurrentContent[i]['Model']} ${invoiceCurrentContent[i]['Grade']} @ ${invoiceCurrentContent[i]['Value']}';
    }
    return returnText;
  }
  void validateContent(){
    int contentNumberOf = invoiceCurrentContent.length;
    for(var i=0;i<contentNumberOf;i+=1){
      if(invoiceCurrentContent[i]['Quantity'] == 0){
        //print('Content $i got empty and was deleted, ${invoiceCurrentContent[i]}');
        invoiceCurrentContent.removeAt(i);
        i-=1;
        contentNumberOf = invoiceCurrentContent.length;
      }
    }
  }
  void addContent (Map<String, dynamic> contentBeingAdded){
    String line = contentBeingAdded['Line'];
    String brand = contentBeingAdded['Brand'];
    String model = contentBeingAdded['Model'];
    String grade = contentBeingAdded['Grade'];
    int quantity = contentBeingAdded['Quantity'];
    double value = contentBeingAdded['Value'];

    bool matchNotFound = true;
    int contentNumberOf = invoiceCurrentContent.length;

    for(var i=0;i<contentNumberOf;i+=1){
      if(invoiceCurrentContent[i]['Line'] == line){
        if(invoiceCurrentContent[i]['Brand'] == brand){
          if(invoiceCurrentContent[i]['Model'] == model) {
            if (invoiceCurrentContent[i]['Grade'] == grade) {
              matchNotFound = false;
              //adding to this invoice
              invoiceCurrentContent[i]['Quantity'] += quantity;
              invoiceCurrentContent[i]['Value'] += value;
              //print('Match found, new content has ${invoiceCurrentContent[i]['Quantity']} valued at ${invoiceCurrentContent[i]['Value']}');
            } else {
              //print('$i: different Grade ${invoiceCurrentContent[i]['Grade']} vs $grade');
            }
          } else {
            //print('$i: different Model ${invoiceCurrentContent[i]['Model']} vs $model');
          }
        } else {
          //print('$i: different Brand ${invoiceCurrentContent[i]['Brand']} vs $brand');
        }
      } else {
        //print('$i: different Line ${invoiceCurrentContent[i]['Line']} vs $line');
      }
    }
    if(matchNotFound){
      invoiceCurrentContent.insert(contentNumberOf, {'Line': line,'Brand': brand,'Model': model, 'Grade': grade, 'Quantity': quantity, 'Value': value});
      //print('No match found.');
      //print('New content added in position ${contentNumberOf + 1}');
    }
  }

  void removeContent (index, quantityBeingRemoved){
    var valueBeingRemoved = invoiceCurrentContent[index]['Value'] / invoiceCurrentContent[index]['Quantity'] * quantityBeingRemoved;
    invoiceCurrentContent[index]['Quantity'] -= quantityBeingRemoved;
    invoiceCurrentContent[index]['Value'] -= valueBeingRemoved;
    //print('removed content $index from $invoiceSerialNumber $invoiceName: $quantityBeingRemoved ${content['Line']} ${content['Brand']} ${content['Model']} ${content['Grade']} @ $valueBeingRemoved');
    validateContent();
  }

  void transferContentPartially (InvoiceInformation other, index, quantityBeingTransferred){
    addContent(other.invoiceCurrentContent[index]);
    other.removeContent(index, quantityBeingTransferred);
  }


}