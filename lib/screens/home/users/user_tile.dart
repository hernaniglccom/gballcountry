import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gballcountry/private_classes/user.dart';

class UserTile extends StatelessWidget {
  final UserInformation user;
  const UserTile({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    /*final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;*/
    final double padding = pow(size.width, 1 / 4) * 1.5;
    //print(user);
    return Padding(
      padding: EdgeInsets.only(top:padding),
      child: Card(
        margin: EdgeInsets.fromLTRB(horizontalPadding, padding, horizontalPadding, padding),
        child: ListTile(
          leading: const Icon(Icons.person, color: Colors.blueAccent),
          title: Text('${user.userName} \n ${user.toString()}'),
          //subtitle: Text(user.userName),
        ),
      )
    );
  }
}
