import 'package:flutter/material.dart';
import 'package:gballcountry/screens/authenticate/authenticate.dart';
import 'package:gballcountry/screens/home/home.dart';
import 'package:provider/provider.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/services/dbaseUser.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);
    //int screenIndex = 0;
    //print(user.userId);
    //return either Home or Authenticate widget, whether the user has provided their credential
    if (user.userId == 'none') {
      return const Authenticate();
    } else {
        return StreamProvider<UserData?>.value(
            value: UserDatabaseService(userId: user.userId).userData,
    initialData: null,
    child: const Home());
    }
  }
}
