import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/services/auth.dart';
import 'package:gballcountry/screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBRRf1C3InRw1UCeml-r_I5y_YLxHBseP8",
          authDomain: "gballcountry.firebaseapp.com",
          projectId: "gballcountry",
          storageBucket: "gballcountry.appspot.com",
          messagingSenderId: "116213751863",
          appId: "1:116213751863:web:05e8148ed852c2dfa99fb2"
      ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser>.value(
      initialData: AppUser(userId: 'none'),
      value: AuthService().user,
      child: const MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}