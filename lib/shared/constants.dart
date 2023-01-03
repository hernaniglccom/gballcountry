import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

///   Widgets

final iconAndTextButtonDecoration = TextButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    padding: const EdgeInsets.all(16.0),
    //backgroundColor: Colors.lightBlue[900],
);

class ProcessButton extends StatelessWidget {
  final String buttonLabel;
  final Icon buttonIcon;
  final Function buttonFunction;
  final int buttonIndex;
  const ProcessButton({Key? key, required this.buttonLabel, required this.buttonIcon, required this.buttonFunction, required this.buttonIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final Size size = MediaQuery.of(context).size;
    //double horizontalPadding = size.width/30;
    //double verticalPadding = size.height/40;
    return Expanded(
      child: SizedBox(
        height: 175,//size.height/5,
        width: 175*1.618,//size.width*3/5,
        child: TextButton.icon(
          label: Text(buttonLabel),
          icon: buttonIcon,
          style: iconAndTextButtonDecoration,
          onPressed: () => buttonFunction(buttonIndex)),
      ),
    );
  }
}

class DismissButton extends StatelessWidget {
  final int n;
  const DismissButton({Key? key, required this.n}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;

    return InkWell(
        child: Container(
          width: size.width/2,
            decoration: BoxDecoration(color: Colors.green[700],
              borderRadius: const BorderRadius.all(Radius.circular(5)),),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding/4),
                      child: const Icon(Icons.thumb_up, color: Colors.white70),
                    ),
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: Text('Dismiss message', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            )),
        onTap: () {
          for(var i=0;i<n;i++) {
            Navigator.pop(context);
          }
        });
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;

    return InkWell(
        child: Container(
            width: size.width/3.3,
            decoration: BoxDecoration(color: Colors.red[700],
              borderRadius: const BorderRadius.all(Radius.circular(5)),),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding/4),
                      child: const Icon(Icons.cancel, color: Colors.white70),
                    ),
                    Padding(
                      padding: EdgeInsets.all(padding),
                      child: Text('Cancel', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            )),
        onTap: () => Navigator.pop(context)
    );
  }
}


///   Functions
String intFixed(int n, int count) => n.toString().padLeft(count, "0");

String timeStampNow(){
  DateTime now = DateTime.now();
  var year = intFixed(now.year,4);
  var month = intFixed(now.month,2);
  var day = intFixed(now.day,2);
  var hour = intFixed(now.hour,2);
  var minute = intFixed(now.minute,2);
  var second = intFixed(now.second,2);
  var millisecond = intFixed(now.millisecond,3);
  return '$year$month$day$hour$minute$second$millisecond';
}

String dateToday(){
  DateTime now = DateTime.now();
  var year = intFixed(now.year,4);
  var month = intFixed(now.month,2);
  var day = intFixed(now.day,2);
  return '$month/$day/$year';
}

String dateTodayStamp(){
  DateTime now = DateTime.now();
  var year = intFixed(now.year,4);
  var month = intFixed(now.month,2);
  var day = intFixed(now.day,2);
  return '$year$month$day';
}
// creating IDs
const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


/// Other elements
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}