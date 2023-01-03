// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/services/dbaseUser.dart';
import 'package:gballcountry/shared/loading.dart';
import 'package:provider/provider.dart';


class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  // form values
  String? _currentName;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;

    final user = Provider.of<AppUser>(context);

    return StreamBuilder<UserData>(
      stream: UserDatabaseService(userId: user.userId).userData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          dynamic userStreamData = snapshot.data;
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(width: (size.width-horizontalPadding)*.1),
                    SizedBox(width: (size.width-horizontalPadding)*.8, child: Text('Update your account information', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeTitle,))),
                    SizedBox(width: (size.width-horizontalPadding)*.1,
                        child: const CloseButton()),
                  ],
                ),
                SizedBox(height: verticalPadding),
                TextFormField(
                  initialValue: userStreamData.userName,
                  style: TextStyle(fontSize: fontSizeText),
                  validator: (val) => val!.isEmpty ? 'Please enter a name': null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                SizedBox(height: verticalPadding),
              InkWell(
                  child: Container(
                      width: size.width/3.3,
                      decoration: const BoxDecoration(color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(5)),),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(padding/4),
                                child: const Icon(Icons.check, color: Colors.white70),
                              ),
                              Padding(
                                padding: EdgeInsets.all(padding),
                                child: Text('Update', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                              ),
                            ],
                          ),
                        ),
                      )),
                  onTap: () async {
                    if(_formKey.currentState!.validate()) {
                      await UserDatabaseService(userId: user.userId).updateUserData(_currentName ?? userStreamData.userName, userStreamData.role, userStreamData.cartContent);
                      Navigator.of(context).pop();
                    }
                  }),
              ],
            ),
          );
        }else{
          return const Loading();
        }
      }
    );
  }
}
