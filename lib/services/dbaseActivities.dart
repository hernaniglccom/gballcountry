// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gballcountry/private_classes/activity.dart';

class ActivityDatabaseService {
  final String activityId;
  ActivityDatabaseService({required this.activityId,});
  //ActivityDatabaseService.withoutActivityId() : activityId = '';

  final CollectionReference gbcActivitiesCollection = FirebaseFirestore.instance
      .collection('/activities');

  Future updateActivity(
      //String activityId,
      String userId,
      String activityType,
      String fromLocation,
      List<dynamic> fromContentDetails,
      String toLocation,
      List<dynamic> transferredContentDetails,
      ) async {
    return await gbcActivitiesCollection.doc(activityId).set({
    'activityId': activityId,
    'userId': userId,
    'activityType': activityType,
    'fromLocation': fromLocation,
    'fromContentDetails': fromContentDetails,
    'toLocation': toLocation,
    'transferredContentDetails': transferredContentDetails,
    });
  }

  Future grading(
      //String activityId,
      String userId,
      String activityType,
      String fromLocation,
      Map<String, dynamic> fromContentDetails,
      Map<String, dynamic> transferredContentDetails,
      ) async {
    return await gbcActivitiesCollection.doc(activityId).set({
      'activityId': activityId,
      'userId': userId,
      'activityType': 'grading',
      'fromLocation': fromLocation,
      'fromContentDetails': fromContentDetails,
      'toLocation': fromLocation,
      'transferredContentDetails': transferredContentDetails,
    });
  }

  //get activity list from snapshot to allow stream of a list of all activities
  List<ActivityInformation> _activityListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map<ActivityInformation>((doc) {
      return ActivityInformation(
          activityId: doc.get('activityId').toInt() ?? '',
          userId: doc.get('userId').toInt() ?? '',
      activityType: doc.get('activityType').toInt() ?? '',
      fromLocation: doc.get('fromLocation').toInt() ?? '',
      fromContentDetails: doc.get('fromContentDetails').toInt() ?? '',
      toLocation: doc.get('toLocation').toInt() ?? '',
      transferredContentDetails: doc.get('transferredContentDetails').toInt() ?? '');
    }).toList();
  }

  // get list of all activitys stream
  Stream<List<ActivityInformation>> get activityInfo {
    return gbcActivitiesCollection.snapshots().map(_activityListFromSnapshot);
  }
}
