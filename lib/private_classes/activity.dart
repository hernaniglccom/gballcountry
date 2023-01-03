class ActivityInformation{
  String activityId;
  String userId;
  String activityType;
  String fromLocation;
  List<dynamic> fromContentDetails;
  String toLocation;
  List<dynamic> transferredContentDetails;

  ActivityInformation({
    required this.activityId,
    required this.userId,
    required this.activityType,
    required this.fromLocation,
    required this.fromContentDetails,
    required this.toLocation,
    required this.transferredContentDetails
  });

  @override
  String toString(){
    String returnText = 'activityId: $activityId,';
    returnText = '$returnText userId: $userId';
    returnText = '$returnText activityType: $activityType';
    returnText = '$returnText fromLocation: $fromLocation, ';
    returnText = '$returnText fromContentDetails: $fromContentDetails, ';
    returnText = '$returnText toLocation: $toLocation, ';
    returnText = '$returnText transferredContentDetails: $transferredContentDetails, ';
      return returnText;
  }
}
