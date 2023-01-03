// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gballcountry/private_classes/fulfilled_order.dart';

class FulfillmentDatabaseService {

  final String orderId;
  FulfillmentDatabaseService({required this.orderId});
  FulfillmentDatabaseService.withoutOrderId() : orderId = '';
  final CollectionReference gbcFulfillmentCollection = FirebaseFirestore.instance.collection('/fulfilledOrders');

  Future updateFulfillmentData(String orderId, String date, String userId, String fromLocation, String skuLine, String skuBrand, String skuModel, String skuGrade, Map<dynamic,dynamic> packageList) async {
    return await gbcFulfillmentCollection.doc(orderId).set({
      'orderId': orderId,
      'date': date,
      'userId': userId,
      'fromLocation': fromLocation,
      'skuLine': skuLine,
      'skuBrand': skuBrand,
      'skuModel': skuModel,
      'skuGrade': skuGrade,
      'packageList': packageList,
    });
  }

  //get fulfillment list from snapshot to allow stream of a list of all orders
  List<FulfillmentInformation> _fulfillmentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<FulfillmentInformation>((doc) {
      return FulfillmentInformation(
        orderId: doc.data().toString().contains('orderId') ? doc.get('orderId') : '',
        date: doc.data().toString().contains('date') ? doc.get('date') : '',
        userId: doc.data().toString().contains('userId') ? doc.get('userId') : '',
        fromLocation: doc.data().toString().contains('fromLocation') ? doc.get('fromLocation') : '',
        skuLine: doc.data().toString().contains('skuLine') ? doc.get('skuLine') : '',
        skuBrand: doc.data().toString().contains('skuBrand') ? doc.get('skuBrand') : '',
        skuModel: doc.data().toString().contains('skuModel') ? doc.get('skuModel') : '',
        skuGrade: doc.data().toString().contains('skuGrade') ? doc.get('skuGrade') : '',
        packageList: doc.data().toString().contains('packageList') ? doc.get('packageList').map((key, value) => MapEntry(key.toString(), value)) : '',
      );
    }).toList();
  }

  // get list of all orders stream
  Stream<List<FulfillmentInformation>> get fulfillmentInfo {
    return gbcFulfillmentCollection.snapshots().map(_fulfillmentListFromSnapshot);
  }
}
