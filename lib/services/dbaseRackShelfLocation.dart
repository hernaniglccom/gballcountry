// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gballcountry/private_classes/warehouse.dart';


class RackDatabaseService {

  final String rackId;
  RackDatabaseService({required this.rackId});
  RackDatabaseService.withoutRackId() : rackId = '';
  final CollectionReference gbcRackCollection = FirebaseFirestore.instance.collection('/rackInfo');

  Future updateRackData(String rackId, int rackArea, String rackName, int shelvesQuantity, List<dynamic> shelvesList) async {
    return await gbcRackCollection.doc(rackId).set({
      'rackArea': rackArea.toInt(),
      'rackName': rackName,
      'shelvesQuantity': shelvesQuantity.toInt(),
      'shelvesList': shelvesList,
    });
  }

  //get rack list from snapshot to allow stream of a list of all racks
  List<RackInformation> _rackListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<RackInformation>((doc) {
      return RackInformation(rackArea: doc.get('rackArea').toInt() ?? '',
        rackName: doc.get('rackName') ?? '',
        shelvesQuantity: doc.get('shelvesQuantity').toInt() ?? '',
        shelvesList: doc.get('shelvesList') ?? '',);
    }).toList();
  }

  // get list of all racks stream
  Stream<List<RackInformation>> get rackInfo {
    return gbcRackCollection.snapshots().map(_rackListFromSnapshot);
  }
}

class ShelfDatabaseService {

  final String shelfId;
  ShelfDatabaseService({required this.shelfId});
  ShelfDatabaseService.withoutShelfId() : shelfId = '';
  final CollectionReference gbcShelfCollection = FirebaseFirestore.instance.collection('/shelfInfo');

  Future updateShelfData(String shelfId, String rackId, String shelfName, int shelfSerialNumber, int locationsQuantity, List<dynamic> locationsList) async {
    return await gbcShelfCollection.doc(shelfId).set({
      'rackId': rackId,
      'shelfName': shelfName,
      'shelfSerialNumber': shelfSerialNumber,
      'locationsQuantity': locationsQuantity.toInt(),
      'locationsList': locationsList,
    });
  }

  //get shelf list from snapshot to allow stream of a list of all shelves
  List<ShelfInformation> _shelfListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<ShelfInformation>((doc) {
      return ShelfInformation(
          rackId: doc.data().toString().contains('rackId') ? doc.get('rackId') : '',
          shelfName: doc.data().toString().contains('shelfName') ? doc.get('shelfName') : '',
          shelfSerialNumber: doc.data().toString().contains('shelfSerialNumber') ? doc.get('shelfSerialNumber') : 1000,
          locationsQuantity: doc.data().toString().contains('locationsQuantity') ? doc.get('locationsQuantity') : 1000,
          locationsList: doc.data().toString().contains('locationsList') ? doc.get('locationsList') : ''
      );
    }).toList();
  }

  // get list of all shelves stream
  Stream<List<ShelfInformation>> get shelfInfo {
    return gbcShelfCollection.snapshots().map(_shelfListFromSnapshot);
  }

}

class LocationDatabaseService {

  final String locationId;
  LocationDatabaseService({required this.locationId});
  LocationDatabaseService.withoutLocationId() : locationId = '';
  final CollectionReference gbcLocationCollection = FirebaseFirestore.instance
      .collection('/locationInfo');

  Future updateLocationData(String locationId, String rackId, String shelfId, int shelfSerialNumber, int positionNumber, String locationName, int locationSerialNumber, List<dynamic> locationContent) async {
    return await gbcLocationCollection.doc(locationId).set({
      'rackId': rackId,
      'shelfId': shelfId,
      'shelfSerialNumber': shelfSerialNumber.toInt(),
      'positionNumber': positionNumber,
      'locationName': locationName,
      'locationSerialNumber': locationSerialNumber.toInt(),
      'locationContent': locationContent,
    });
  }

  //get location list from snapshot to allow stream of a list of all locations
  List<LocationInformation> _locationListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<LocationInformation>((doc) {
      return LocationInformation(
          rackId: doc.data().toString().contains('rackId') ? doc.get('rackId') : '',
          shelfId: doc.data().toString().contains('shelfId') ? doc.get('shelfId') : '',
          shelfSerialNumber: doc.data().toString().contains('shelfSerialNumber') ? doc.get('shelfSerialNumber') : 1000,
          positionNumber: doc.data().toString().contains('positionNumber') ? doc.get('positionNumber') : 1000,
          locationName: doc.data().toString().contains('locationName') ? doc.get('locationName') : '',
          locationSerialNumber: doc.data().toString().contains('locationSerialNumber') ? doc.get('locationSerialNumber').toInt() : '',
          locationContent: doc.data().toString().contains('locationContent') ? doc.get('locationContent') : ''
      );
    }).toList();
  }

  // get list of all locations stream
  Stream<List<LocationInformation>> get locationInfo {
    return gbcLocationCollection.snapshots().map(_locationListFromSnapshot);
  }
}