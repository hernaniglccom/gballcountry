import 'package:flutter/material.dart';

import 'package:gballcountry/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red[100],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[900],
        elevation: 0.0,
        title: const Text('Sign in with your account'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Center(
          child: ElevatedButton(
              child: const Text('Sign anonymously'),
              onPressed: () async{
                dynamic result = await _auth.signInAnon();
                if (result == null){
                  //print('Error signing in anonymously.');
                }else{
                  //print('signed in');
                  //print(result);
                }
            }
          ),
        ),
      ),
    );
  }
}
