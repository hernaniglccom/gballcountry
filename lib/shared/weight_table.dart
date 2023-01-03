// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class WeightTable extends StatefulWidget {
  const WeightTable({Key? key}) : super(key: key);

  @override
  State<WeightTable> createState() => _WeightTableState();
}

class _WeightTableState extends State<WeightTable> {

  /// variables to populate tables
  static List<String> containerName = [
    'Pallet',
    'Menards Bucket',
    'Grading Bucket',
    'GBMonster Box',
    'Large Box for 72 and 100ct',
    'Medium Box for 48 and 50ct',
    'Small Box for 12, 24 and 30ct'];
  static List<double> containerWeightInLbs = [
    40,
    0.75,
    0.5,
    0.25,
    .15,
    .1,
    .05];
  List<int> containerQuantity = [
    0,
    0,
    0,
    0,
    0,
    0,
    0];
  static double golfBallsPerLb = 453.952/45.88; /// grams per lb divided by grams per golf ball
  static List<int> golfBallsAmounts = [1, 12, 24, 36, 48, 50, 72, 100, 300, 600, 1000, 13000];
  List<double> weightList = [];
  int nBalls = 0;
  double weight = 0;

  void updateNBalls(double weight){
    nBalls = (weight * golfBallsPerLb).toInt();
    for(var i=0;i<containerName.length;i++){
      nBalls -= (containerQuantity[i] * containerWeightInLbs[i] * golfBallsPerLb).toInt();
    }

  }
  
  TextEditingController _weightMeasured = TextEditingController();
  @override
  void initState() {
    super.initState();
    _weightMeasured = TextEditingController();
  }

  @override
  void dispose() {
    _weightMeasured.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    bool largerThanTall = size.width > size.height ? true : false;

    /// variables to facilitate distributing space among widgets
    int nColumns = largerThanTall ? 6 : 4;
    double columnWidth = size.width / nColumns - nColumns * padding;
    double columnWidthLimit = largerThanTall ? 182 : 155;
    double rowHeightOneLine = 75;
    double rowHeightTwoLines = 45;

    Widget golfBallsToWeightTable = Flexible(
      flex: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding( ///header
              padding: EdgeInsets.symmetric(
                  vertical: padding, horizontal: 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(padding)), color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: largerThanTall ? columnWidth : columnWidth * 1.75,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Number of Golf Balls', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  ),
                  Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(padding)), color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: largerThanTall ? columnWidth : columnWidth * 1.75,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Weight in lbs', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  )
                ],
              )
          ),
          ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: golfBallsAmounts.length,
              itemBuilder: (context, index) {
                weightList.insert(index, golfBallsAmounts[index] / golfBallsPerLb);
                return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: padding, horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            width: columnWidth,
                            child: Text(NumberFormat('#,##0').format(golfBallsAmounts[index]), style: TextStyle(fontSize: fontSizeText), textAlign: TextAlign.center)),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            width: columnWidth,
                            child: Text(NumberFormat('#,##0').format(weightList[index]), style: TextStyle(fontSize: fontSizeText), textAlign: TextAlign.center,))
                      ],
                    )
                );
              }
          ),
        ],
      ),
    );
    Widget containersInfoTable = Flexible(
      flex: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding( ///header
              padding: EdgeInsets.symmetric(
                  vertical: padding, horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(padding)), color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: columnWidth * 1.25,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Type of Container', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  ),
                  Container(
                      decoration: BoxDecoration(color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: columnWidth * .75,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Lbs/unit', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  ),
                  Container(
                      decoration: BoxDecoration(color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: columnWidth,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Quantity', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  ),
                  Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(padding)), color: Colors.lightBlue[900]),
                      padding: EdgeInsets.all(padding),
                      width: columnWidth,
                      height: columnWidth < columnWidthLimit ? rowHeightOneLine : rowHeightTwoLines,
                      child: Center(child: Text('Total Weight (lbs)', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.white70)))
                  )
                ],
              )
          ),
          ListView.builder( /// container
              shrinkWrap: true,
              primary: false,
              //reverse: true,
              itemCount: containerName.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: padding, horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding*2),
                            width: columnWidth * 1.25,
                            child: Text(containerName[index], style: TextStyle(fontSize: fontSizeText))),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            width: columnWidth * .75,
                            child: Text('${containerWeightInLbs[index]}', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText))),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            width: columnWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      containerQuantity[index]++;
                                      updateNBalls(weight);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.green,
                                        borderRadius: BorderRadius.all(Radius.circular(padding))),
                                    padding: EdgeInsets.all(padding/2),
                                    child: const Icon(Icons.add, color: Colors.white70,),
                                  ),
                                ),
                                const Spacer(),
                                Text('${containerQuantity[index]}', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText)),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      containerQuantity[index]--;
                                      updateNBalls(weight);
                                    });
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(color: Colors.red,
                                          borderRadius: BorderRadius.all(Radius.circular(padding))),
                                      padding: EdgeInsets.all(padding/2),
                                      child: const Icon(Icons.remove, color: Colors.white70)
                                  ),
                                ),
                              ],)
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: padding),
                            width: columnWidth,
                            child: Text(NumberFormat('#,##0').format(containerQuantity[index] * containerWeightInLbs[index]), textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeText))),
                      ],
                    )
                );
              }
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: (size.width-horizontalPadding)*.2),
              SizedBox(width: (size.width-horizontalPadding)*.6,
                  child: Text('Quantity Estimator', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeTitle))),
              SizedBox(width: (size.width-horizontalPadding)*.2,
                  child: const CloseButton()),
            ],
          ),
          SizedBox(height: verticalPadding,),
          Padding(
            padding: EdgeInsets.all(padding * 2),
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(padding)), color: Colors.lightBlue[700]),
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(padding),
                          width: largerThanTall ? columnWidth * 3 : columnWidth * 2,
                          child: Text(((columnWidth > columnWidthLimit) || largerThanTall) ? 'Estimated Golf Balls Quantity' : 'Estimated Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70)
                          )
                      ),
                      Container(
                        padding: EdgeInsets.all(padding),
                        width: columnWidth * 2,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(padding)), color: Colors.white70),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(NumberFormat('#,##0').format(nBalls), textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeSubtitle)),
                            const Spacer(),
                            Tooltip(
                              message: 'Copy ${NumberFormat('#,##0').format(nBalls)}',
                              child: InkWell(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(text: nBalls.toString())); /// adding nBalls value to user's clipboard
                                },
                                child:const Icon(Icons.copy),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(padding),
                          child: Text('Total Weight', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70))
                      ),
                      Container(
                        padding: EdgeInsets.all(padding),
                        width: columnWidth * 2,
                        child: TextFormField(
                          controller: _weightMeasured,
                          decoration: InputDecoration(
                            labelText: 'Type here',
                            filled: true,
                            fillColor: Colors.white70,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(width: 0, color: Colors.white70),
                              borderRadius: BorderRadius.circular(padding),
                            ),
                          ),
                          onChanged: (v){setState((){
                            weight = double.parse(v);
                            updateNBalls(weight);
                          });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalPadding,),
          largerThanTall ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                golfBallsToWeightTable,
                containersInfoTable
              ],
          ) :
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              containersInfoTable,
              SizedBox(height: verticalPadding*2),
              golfBallsToWeightTable,
            ],
          ),
        ],
      ),
    );
  }
}
