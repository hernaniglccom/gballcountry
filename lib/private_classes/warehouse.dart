class RackData{
  String rackId;
  String rackName;
  int rackArea;
  int shelvesQuantity;
  List<int> shelvesList;
  RackData({required this.rackId, required this.rackName, required this.rackArea, required this.shelvesQuantity, required this.shelvesList});
  @override
  String toString() => "rackId: $rackId, rackName: $rackName, rackArea: $rackArea, shelvesQuantity: $shelvesQuantity, shelvesList: $shelvesList";
}
class RackInformation {
  String rackName;
  int rackArea;
  int shelvesQuantity;
  List<dynamic> shelvesList;
  RackInformation({required this.rackName, required this.rackArea, required this.shelvesQuantity, required this.shelvesList});
  @override
  String toString() => "rackName: $rackName, rackArea: $rackArea, shelvesQuantity: $shelvesQuantity, shelvesList: $shelvesList";
}

class ShelfData{
  String rackId;
  String shelfId;
  String shelfName;
  int shelfSerialNumber;
  int locationsQuantity;
  List<dynamic> locationsList;
  ShelfData({required this.rackId, required this.shelfId, required this.shelfName, required this.shelfSerialNumber, required this.locationsQuantity, required this.locationsList});
  @override
  String toString() => "rackId: $rackId, shelfId: $shelfId, shelfName: $shelfName, shelfSerialNumber: $shelfSerialNumber, locationsQuantity: $locationsQuantity, locationsList: $locationsList";
}

class ShelfInformation{
  String rackId;
  String shelfName;
  int shelfSerialNumber;
  int locationsQuantity;
  List<dynamic> locationsList;
  ShelfInformation({required this.rackId, required this.shelfName, required this.shelfSerialNumber, required this.locationsQuantity, required this.locationsList});
  @override
  String toString() => "rackId: $rackId, shelfName: $shelfName, shelfSerialNumber: $shelfSerialNumber, locationsQuantity: $locationsQuantity, locationsList: $locationsList";
}

class LocationData{
  String rackId;
  String shelfId;
  int shelfSerialNumber;
  String locationId;
  int positionNumber;
  String locationName;
  int locationSerialNumber;
  List<dynamic> locationContent;
  LocationData({required this.rackId, required this.shelfId, required this.shelfSerialNumber, required this.locationId, required this.positionNumber, required this.locationName, required this.locationSerialNumber, required this.locationContent});
  @override
  String toString() => "rackId: $rackId, shelfId: $shelfId, shelfSerialNumber: $shelfSerialNumber, locationId: $locationId, positionNumber: $positionNumber, locationName: $locationName, locationSerialNumber: $locationSerialNumber, locationContent: $locationContent";
}

class LocationInformation{
  String rackId;
  String shelfId;
  int shelfSerialNumber;
  int positionNumber;
  String locationName;
  int locationSerialNumber;
  List<dynamic> locationContent;
  LocationInformation({required this.rackId, required this.shelfId, required this.shelfSerialNumber, required this.positionNumber, required this.locationName, required this.locationSerialNumber, required this.locationContent});
  @override
  String toString(){
    var returnText = 'rackId: $rackId, shelfId: $shelfId, shelfSerialNumber: $shelfSerialNumber, positionNumber: $positionNumber, locationName: $locationName, locationSerialNumber: $locationSerialNumber; \n Contents: ';
    for(var i=0;i<locationContent.length;i+=1){
      returnText = '$returnText \n - ${locationContent[i]['Quantity']} ${locationContent[i]['Line']} ${locationContent[i]['Brand']} ${locationContent[i]['Model']} ${locationContent[i]['Grade']} @ ${locationContent[i]['Value']}';
    }
    return returnText;
  }
  void validateContent(){
    int contentNumberOf = locationContent.length;
    for(var i=0;i<contentNumberOf;i+=1){
      if(locationContent[i]['Quantity'] == 0){
        locationContent.removeAt(i);
        i-=1;
        contentNumberOf = locationContent.length;
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
    int contentNumberOf = locationContent.length;

    for(var i=0;i<contentNumberOf;i+=1){
      if(locationContent[i]['Line'] == line){
        if(locationContent[i]['Brand'] == brand){
          if(locationContent[i]['Model'] == model) {
            if (locationContent[i]['Grade'] == grade) {
              matchNotFound = false;
              //adding to this location
              locationContent[i]['Quantity'] += quantity;
              locationContent[i]['Value'] += value;
              //print('Match found, new content has ${locationContent[i]['Quantity']} valued at ${locationContent[i]['Value']}');
            } else {
              //print('$i: different Grade ${locationContent[i]['Grade']} vs $grade');
            }
          } else {
            //print('$i: different Model ${locationContent[i]['Model']} vs $model');
          }
        } else {
          //print('$i: different Brand ${locationContent[i]['Brand']} vs $brand');
        }
      } else {
        //print('$i: different Line ${locationContent[i]['Line']} vs $line');
      }
    }
    if(matchNotFound){
      locationContent.insert(contentNumberOf, {'Line': line,'Brand': brand,'Model': model, 'Grade': grade, 'Quantity': quantity, 'Value': value});
      //print('No match found.');
      //print('New content added in position ${contentNumberOf + 1}');
    }
  }

  void removeContent (index, quantityBeingRemoved){
    var valueBeingRemoved = locationContent[index]['Value'] / locationContent[index]['Quantity'] * quantityBeingRemoved;
    locationContent[index]['Quantity'] -= quantityBeingRemoved;
    locationContent[index]['Value'] -= valueBeingRemoved;
    //print('removed content $index from $shelfId $locationSerialNumber $locationName: $quantityBeingRemoved ${content['Line']} ${content['Brand']} ${content['Model']} ${content['Grade']} @ $valueBeingRemoved');
    validateContent();
  }

  void transferContentPartially (LocationInformation other, index, quantityBeingTransferred){
    addContent(other.locationContent[index]);
    other.removeContent(index, quantityBeingTransferred);
  }


}