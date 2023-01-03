// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gballcountry/private_classes/user.dart';

class UserDatabaseService{

  final String userId;
  UserDatabaseService({required this.userId});
  UserDatabaseService.withoutUserId() : userId = '';

  final CollectionReference gbcUsersCollection = FirebaseFirestore.instance.collection('userInfo');

  Future updateUserData(String userName, String role, List<dynamic> cartContent) async {
    return await gbcUsersCollection.doc(userId).set({
      'userName': userName,
      'role' : role,
      'cartContent': cartContent,
    });
  }

  //get user list from snapshot to allow stream of a list of all users
  List<UserInformation> _userListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return UserInformation(userName: doc.get('userName')??'', role: doc.get('role')??'', cartContent: doc.get('cartContent')??'');
    }).toList();
  }

  // get list of all users stream
  Stream<List<UserInformation>> get userInfo {
    return gbcUsersCollection.snapshots().map(_userListFromSnapshot);
  }

  //get userData from snapshot to allow stream of a single user
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot){
    return  UserData(userId: userId, role: snapshot['role'], userName: snapshot['userName'], cartContent: snapshot['cartContent']);
  }

  //get a single user doc stream
  Stream<UserData> get userData{
    return gbcUsersCollection.doc(userId).snapshots().map(_userDataFromSnapshot);
  }

}