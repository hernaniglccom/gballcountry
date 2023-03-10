import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/private_classes/user.dart';

import 'package:gballcountry/screens/home/users/user_tile.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    final users = Provider.of<List<UserInformation>>(context);
    //print('users $users');

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index){
        return UserTile(user: users[index]);
      },
    );
  }
}
