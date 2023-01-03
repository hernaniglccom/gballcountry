// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gballcountry/private_classes/invoice.dart';
import 'package:gballcountry/private_classes/vendor.dart';

class VendorDatabaseService {

  final String vendorId;
  VendorDatabaseService({required this.vendorId});
  VendorDatabaseService.withoutVendorId() : vendorId = '';
  final CollectionReference gbcVendorCollection = FirebaseFirestore.instance.collection('/vendorInfo');

  Future updateVendorData(String vendorId, String vendorName) async {
    return await gbcVendorCollection.doc(vendorId).set({
      'vendorName': vendorName,
    });
  }

  //get vendor list from snapshot to allow stream of a list of all vendors
  List<VendorInformation> _vendorListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<VendorInformation>((doc) {
      return VendorInformation(
          vendorName: doc.data().toString().contains('vendorName') ? doc.get('vendorName') : '',
      );
    }).toList();
  }

  // get list of all vendors stream
  Stream<List<VendorInformation>> get vendorInfo {
    return gbcVendorCollection.snapshots().map(_vendorListFromSnapshot);
  }
}

class InvoiceDatabaseService {

  final String invoiceId;
  InvoiceDatabaseService({required this.invoiceId});
  InvoiceDatabaseService.withoutInvoiceId() : invoiceId = '';
  final CollectionReference gbcInvoiceCollection = FirebaseFirestore.instance
      .collection('/invoiceInfo');

  Future updateInvoiceData(String invoiceId, String vendorName, String invoiceName, int invoiceSerialNumber, List<dynamic> invoiceCurrentContent, List<dynamic> invoiceOriginalContent) async {
    return await gbcInvoiceCollection.doc(invoiceId).set({
      'vendorName': vendorName,
      'invoiceName': invoiceName,
      'invoiceSerialNumber': invoiceSerialNumber.toInt(),
      'invoiceCurrentContent': invoiceCurrentContent,
      'invoiceOriginalContent': invoiceOriginalContent,
    });
  }

  //get invoice list from snapshot to allow stream of a list of all invoices
  List<InvoiceInformation> _invoiceListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<InvoiceInformation>((doc) {
      return InvoiceInformation(
          vendorName: doc.data().toString().contains('vendorName') ? doc.get('vendorName') : '',
          invoiceName: doc.data().toString().contains('invoiceName') ? doc.get('invoiceName') : '',
          invoiceSerialNumber: doc.data().toString().contains('invoiceSerialNumber') ? doc.get('invoiceSerialNumber').toInt() : 1000,
          invoiceCurrentContent: doc.data().toString().contains('invoiceCurrentContent') ? doc.get('invoiceCurrentContent') : '',
          invoiceOriginalContent: doc.data().toString().contains('invoiceOriginalContent') ? doc.get('invoiceOriginalContent') : ''
      );
    }).toList();
  }

  // get list of all invoices stream
  Stream<List<InvoiceInformation>> get invoiceInfo {
    return gbcInvoiceCollection.snapshots().map(_invoiceListFromSnapshot);
  }
}