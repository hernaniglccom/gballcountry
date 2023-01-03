import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/screens/processes/view_stock/location_view.dart';
import 'package:gballcountry/screens/processes/view_stock/golfballsdetailed.dart';

import 'package:gballcountry/shared/loading.dart';

import 'package:gballcountry/private_classes/warehouse.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';

class StockSummary extends StatefulWidget {
  const StockSummary({Key? key}) : super(key: key);
  

  @override
  State<StockSummary> createState() => _StockSummaryState();
}

class _StockSummaryState extends State<StockSummary> {
  //int shelfSelected = 0;
  int shelfSerialNumberSelected = 0;
  String shelfSelectedId = '';
  int positionSelected = 0;
  bool firstRun = true;
  var gbLineBrandHide = <String, bool>{};

  void _showBottomPanel(String reference, List<ShelfInformation> allShelves, List<int> locationsList, List<LocationInformation> allLocations, bool locationSelected, String showText){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      //final double horizontalPadding = size.width/30;
      final double verticalPadding = size.height/40;
      final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;
      final double padding = pow(size.width, 1 / 4) * 1.5;
      String locationsText = '$reference golf balls are available at the following locations:';

      return SingleChildScrollView(
        child:
          Column(
            children: [
              SizedBox(height:verticalPadding/3),
              Text(locationsText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSizeSubtitle)),
              Wrap(
                children:
                  List.generate(
                      locationsList.length,
                          (index){
                        var location = allLocations[locationsList[index]];
                        return Padding(
                          padding: EdgeInsets.all(verticalPadding/3),
                          child: InkWell(
                            onTap: () {
                              //print(locationsList);
                              shelfSelectedId = location.shelfId;
                              shelfSerialNumberSelected = location.shelfSerialNumber;
                              positionSelected = location.positionNumber-1;
                              //print('shelfSelectedId: $shelfSelectedId shelfSerialNumberSelected: $shelfSerialNumberSelected, positionSelected: $positionSelected, locationSerialNumber: ${allLocations[locationsList[index]].locationSerialNumber}');
                              showText = 'Rack ${location.rackId}, Shelf ${location.shelfId}, Position ${location.locationName} \n Contents:';
                              for (var i=0;i<location.locationContent.length;i+=1){
                                var contentLine = location.locationContent[i];
                                showText = '$showText\n - ${NumberFormat('#,##0').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}';
                              }
                              locationSelected = !locationSelected;
                              Navigator.pop(context);
                              _showBottomPanel(reference, allShelves, locationsList, allLocations, true, showText);
                            },
                            child: Container(
                      width: fontSizeSubtitle*3,
                      height: fontSizeSubtitle*3,
                      decoration: BoxDecoration(
                            color: Colors.lightBlue[700],
                            borderRadius: BorderRadius.all(Radius.circular(padding)),
                      ),
                      child: Center(
                            child: Text('${locationsList[index]}',//Text('${position.rackId} ${position.shelfId} ${position.locationName}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: fontSizeSubtitle, color:Colors.white70)),
                      ),
                    ),
                          ),
                        );
                  }),
                ),
              Padding(
                padding: EdgeInsets.all(locationSelected ? 0 : 8.0),
                child: Text(locationSelected ? '' : 'Select any location to see its details',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSizeSubtitle, color:Colors.black38)),
              ),
          locationSelected ?
          StreamProvider<List<ShelfInformation>>.value(
              value: ShelfDatabaseService.withoutShelfId().shelfInfo,
              initialData: allShelves,
              child: StreamProvider<List<LocationInformation>>.value(
                  value: LocationDatabaseService.withoutLocationId().locationInfo,
                  initialData: allLocations,
                  child: LocationView(shelfSerialNumber: shelfSerialNumberSelected, positionNumber: positionSelected)
              )
          ) : const SizedBox.shrink(),
              SizedBox(height:verticalPadding),
            ],
          ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    double horizontalPadding = size.width/30;
    double verticalPadding = size.height/40;
    double fontSizeTitle = pow(size.height, 1/2).toDouble();
    double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;
    double fontSizeText = pow(size.height, 1/2) / (2.5);
    var nColumns = 4;
    var lineFlex = 1.75;
    var qtyFlex = .75;
    var valFlex = 1;
    var vpgbFlex = .5;

    num numberOfBallsOnHands = 0;
    double valueOfBallsOnHands = 0;
    ///variables to allow summary per Line
    List<String> gbLineList = gbLineListDetailed;
    var gbLineQty = <String, num>{gbLineList[0]: 0, gbLineList[1]: 0, gbLineList[2]: 0, gbLineList[3]: 0, gbLineList[4]: 0};
    var gbLineValue = <String, double>{gbLineList[0]: 0, gbLineList[1]: 0, gbLineList[2]: 0, gbLineList[3]: 0, gbLineList[4]: 0};
    var gbLineLocations = <String, List<int>>{gbLineList[0]: [], gbLineList[1]: [], gbLineList[2]: [], gbLineList[3]: [], gbLineList[4]: []};

    ///variables to allow summary per Brand
    var gbLineBrandMap = gbLineBrandMapDetailed;

    ///variables to allow summary per SKU
    List<String> gbGradeList = gbGradeListDetailed;
    var gbBrandModelMap = gbBrandModelMapDetailed;
    var gbDetailedQty = golfBallsDetailedQty;
    var gbDetailedValue = golfBallsDetailedValue;
    var gbDetailedLocations = golfBallsDetailedLocations;

    var gbLineBrandQty = <String, num>{};
    var gbLineBrandValue = <String, double>{};
    var gbLineBrandLocations = <String, List<int>>{};

    final locations = Provider.of<List<LocationInformation>>(context);
    final shelves = Provider.of<List<ShelfInformation>>(context);

    for(var i=0;i<gbLineList.length;i+=1){
      for(var j=0;j<gbLineBrandMap[gbLineList[i]]!.length;j+=1){
        gbLineBrandQty.addAll({'${gbLineList[i]} ${gbLineBrandMap[gbLineList[i]]![j]}':0});
        gbLineBrandValue.addAll({'${gbLineList[i]} ${gbLineBrandMap[gbLineList[i]]![j]}':0});
        gbLineBrandLocations.addAll({'${gbLineList[i]} ${gbLineBrandMap[gbLineList[i]]![j]}':[]});
        firstRun ? gbLineBrandHide.addAll({'${gbLineList[i]} ${gbLineBrandMap[gbLineList[i]]![j]}': true}) : null;
      }
    }
    //print(locations[0]);

    for(var i=0; i<locations.length; i+=1) {
      //print('$i ${locations[i].positionNumber}');
      locations[i].validateContent();
      for(var j=0; j<locations[i].locationContent.length; j+=1){
        var thisLocationContent = locations[i].locationContent[j];
        var thisLocQty = thisLocationContent['Quantity'];
        var thisLocValue = thisLocationContent['Value'];
        var thisLocLine = thisLocationContent['Line'];
        var thisLocBrand = thisLocationContent['Brand'];
        var thisLocModel = thisLocationContent['Model'];
        var thisLocGrade = thisLocationContent['Grade'];
        var thisLocSKU = '$thisLocLine $thisLocBrand $thisLocModel $thisLocGrade';
        //print('i: $i, j: $j, $thisLocQty $thisLocSKU $thisLocValue ');

        numberOfBallsOnHands += (thisLocQty);

        gbLineQty[thisLocLine] = gbLineQty[thisLocLine]! + thisLocQty;
        gbLineBrandQty['$thisLocLine $thisLocBrand'] = gbLineBrandQty['$thisLocLine $thisLocBrand']! + thisLocQty;
        firstRun ? gbDetailedQty[thisLocSKU] = thisLocQty + gbDetailedQty[thisLocSKU]! : null;

        valueOfBallsOnHands += thisLocValue;
        gbLineValue[thisLocLine] = gbLineValue[thisLocLine]! + thisLocValue;
        gbLineBrandValue['$thisLocLine $thisLocBrand'] = gbLineBrandValue['$thisLocLine $thisLocBrand']! + thisLocValue;
        firstRun ? gbDetailedValue[thisLocSKU] = gbDetailedValue[thisLocSKU]! + thisLocValue : null;

        if(firstRun){
          if(!(gbLineLocations[thisLocLine]!.contains(i)) & (gbLineLocations[thisLocLine] != null)){
            gbLineLocations[thisLocLine]!.insert(gbLineLocations[thisLocLine]!.length, i);
          }
          if(!(gbLineBrandLocations['$thisLocLine $thisLocBrand']!.contains(i)) & (gbLineBrandLocations['$thisLocLine $thisLocBrand'] != null)) {
            gbLineBrandLocations['$thisLocLine $thisLocBrand']!.insert(gbLineBrandLocations['$thisLocLine $thisLocBrand']!.length, i);
          }
          if(!(gbDetailedLocations[thisLocSKU]!.contains(locations[i].locationSerialNumber)) & (gbDetailedLocations[thisLocSKU] != null)) {
            gbDetailedLocations[thisLocSKU]!.insert(gbDetailedLocations[thisLocSKU]!.length, locations[i].locationSerialNumber);
            if(thisLocBrand =='Titleist'){
              //print('$i $thisLocSKU ${gbDetailedLocations[thisLocSKU]!}');
            }
          }
        }
      }
    }
    locations[0] == null ? null : firstRun = false;

    var styleHeader = TextStyle(fontSize: fontSizeSubtitle, color: Colors.lightBlue[700]);
    var styleLine = TextStyle(fontSize: fontSizeText, color: Colors.white, fontWeight: FontWeight.bold);
    var styleBrand = TextStyle(fontSize: fontSizeText, color: Colors.lightBlue[700]);
    var styleSKU = TextStyle(fontSize: fontSizeText, color: Colors.black87);

    return StreamBuilder<List<LocationInformation>>(
        stream: LocationDatabaseService.withoutLocationId().locationInfo,
        builder: (context, snapshot) {
    if(snapshot.hasData){
      return SingleChildScrollView(
        child:
               Center(
                 child: Container(
                    //color: Colors.black,
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                              children: [
                                  Text('Total Golf Balls in stock:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: fontSizeTitle, color: Colors.lightBlue[500])),
                                   SizedBox(height:fontSizeText),
                                   Text(' ${NumberFormat('#,##0').format(numberOfBallsOnHands)}        ${NumberFormat('\$#,##0.00').format(valueOfBallsOnHands)}        ${NumberFormat('\$#,##0.00').format(valueOfBallsOnHands/numberOfBallsOnHands)}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: fontSizeTitle*1.2, color: Colors.lightBlue[700], fontWeight: FontWeight.bold)),
                                SizedBox(height: verticalPadding),
                                ///Printing header -----------------------------------------------------------------------------
                                Row(
                                  children: [
                                    SizedBox(
                                      width: (size.width - 2*horizontalPadding)/nColumns*lineFlex,
                                      child: Text('Line',
                                          textAlign: TextAlign.center,
                                          style: styleHeader),
                                    ),
                                    SizedBox(
                                      width: (size.width - 2*horizontalPadding)/nColumns*qtyFlex,
                                      child: Text(' Quantity',
                                          textAlign: TextAlign.center,
                                          style: styleHeader),
                                    ),
                                    SizedBox(
                                      width: (size.width - 2*horizontalPadding)/nColumns*valFlex,
                                      child: Text(' Value',
                                          textAlign: TextAlign.center,
                                          style: styleHeader),
                                    ),
                                    SizedBox(
                                      width: (size.width - 2*horizontalPadding)/nColumns*vpgbFlex,
                                      child: Text(' VpGB',
                                          textAlign: TextAlign.center,
                                          style: styleHeader),
                                    ),
                                  ],
                                ),
                                SizedBox(height: verticalPadding/2),
                                ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: gbLineList.length,
                                    itemBuilder: (context, index){
                                      var thisLine = gbLineList[index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          /// Printing Lines -----------------------------------------------------------------------------
                                          Container(
                                            color: Colors.lightBlue[700],
                                            child: Row(
                                              children: [

                                                SizedBox(
                                                  width: (size.width - 2*horizontalPadding)/nColumns*lineFlex,
                                                  child: //add Inkwell here if desired to 'zoom' into lines
                                                  Text(' $thisLine',
                                                      textAlign: TextAlign.center,
                                                      style: styleLine,)
                                                ),
                                                SizedBox(
                                                  width: (size.width - 2*horizontalPadding)/nColumns*qtyFlex,
                                                  child: Text('${NumberFormat('#,##0').format(gbLineQty[thisLine])} (${NumberFormat('##.#').format(gbLineQty[thisLine]!/numberOfBallsOnHands*100)}%)',
                                                      textAlign: TextAlign.center,
                                                      style: styleLine),
                                                ),
                                                SizedBox(
                                                  width: (size.width - 2*horizontalPadding)/nColumns*valFlex,
                                                  child: Text(' ${NumberFormat('\$#,##0.00').format(gbLineValue[thisLine])} (${NumberFormat('##.#').format(gbLineValue[thisLine]!/valueOfBallsOnHands*100)}%)',
                                                      textAlign: TextAlign.center,
                                                      style: styleLine),
                                                ),
                                                SizedBox(
                                                  width: (size.width - 2*horizontalPadding)/nColumns*vpgbFlex,
                                                  child: Text(' ${NumberFormat('\$#,##0.00').format(gbLineValue[thisLine]!/gbLineQty[thisLine]!)}',
                                                      textAlign: TextAlign.center,
                                                      style: styleLine),
                                                ),
                                                SizedBox(height: verticalPadding*1.2)
                                              ],
                                            ),
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount: gbLineBrandMap[thisLine]!.length,
                                              itemBuilder: (context, index2){
                                                var thisBrand = gbLineBrandMap[gbLineList[index]]![index2];
                                                var thisBrandValue = gbLineBrandValue['$thisLine $thisBrand']! == 0 ? 0 : gbLineBrandValue['$thisLine $thisBrand']!/gbLineBrandQty['$thisLine $thisBrand']!;
                                                return Column(
                                                  children: [
                                                    /// Printing Brands -----------------------------------------------------------------------------
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          gbLineBrandHide['$thisLine $thisBrand'] = !gbLineBrandHide['$thisLine $thisBrand']!;
                                                        });
                                                        //print('tapped');
                                                      },
                                                      child: Row(
                                                        children: [ //gbLineBrandHide
                                                          SizedBox(
                                                            width: (size.width - 2*horizontalPadding)/nColumns*lineFlex,
                                                            child:  Row(
                                                                    children: [
                                                                      Icon(
                                                                        gbLineBrandHide['$thisLine $thisBrand']! ? Icons.expand_more : Icons.expand_less,//add_circle_outline,
                                                                        color: Colors.lightBlue[700],
                                                                        //padding: EdgeInsets.all(padding),
                                                                      ),
                                                                      Text(' $thisBrand',
                                                                          textAlign: TextAlign.left,
                                                                          style: styleBrand)
                                                                    ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: (size.width - 2*horizontalPadding)/nColumns*qtyFlex,
                                                            child: Text(' ${NumberFormat('#,##0').format(gbLineBrandQty['$thisLine $thisBrand'])}',
                                                                textAlign: TextAlign.right,
                                                                style: styleBrand),
                                                          ),
                                                          SizedBox(
                                                            width: (size.width - 2*horizontalPadding)/nColumns*valFlex,
                                                            child: Text(' ${NumberFormat('\$#,##0.00').format(gbLineBrandValue['$thisLine $thisBrand'])}',
                                                                textAlign: TextAlign.right,
                                                                style: styleBrand),
                                                          ),
                                                          SizedBox(
                                                            width: (size.width - 2*horizontalPadding)/nColumns*vpgbFlex,
                                                            child: Text(' ${NumberFormat('\$#,##0.00').format(thisBrandValue)}',
                                                                textAlign: TextAlign.right,
                                                                style: styleBrand),
                                                          ),
                                                          //SizedBox(height: verticalPadding*1.2)
                                                        ],
                                                      ),
                                                    ),
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        primary: false,
                                                        itemCount: gbBrandModelMap['$thisLine $thisBrand']!.length,
                                                        itemBuilder: (context, index3){
                                                          var thisModel = gbBrandModelMap['$thisLine $thisBrand']![index3];
                                                          return gbLineBrandHide['$thisLine $thisBrand']! ? const SizedBox.shrink() :
                                                          Column(
                                                            children: [
                                                              ListView.builder(
                                                                  shrinkWrap: true,
                                                                  primary: false,
                                                                  itemCount: gbGradeList.length,
                                                                  itemBuilder: (context, index4) {
                                                                    /// Printing SKUs -----------------------------------------------------------------------------
                                                                    var thisGrade = gbGradeList[index4];
                                                                    var thisSKU = '$thisLine $thisBrand $thisModel $thisGrade';
                                                                    if(gbDetailedQty[thisSKU] == null){
                                                                      return const SizedBox.shrink();
                                                                    }else{
                                                                      var thisModelValue = gbDetailedValue[thisSKU]! == 0? 0 : gbDetailedValue[thisSKU]!/gbDetailedQty[thisSKU]!;
                                                                      return Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                firstRun = false;
                                                                                _showBottomPanel(thisSKU, shelves, gbDetailedLocations[thisSKU]!, locations, false, '');
                                                                              },
                                                                              child: Row(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: (size.width - 2*horizontalPadding)/nColumns*lineFlex,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.open_in_new,//add_circle_outline,
                                                                                          //size: fontSizeText,
                                                                                          color: Colors.lightBlue[700],
                                                                                          //padding: EdgeInsets.all(padding),
                                                                                        ),
                                                                                        Text('   $thisModel $thisGrade',
                                                                                            textAlign: TextAlign.left,
                                                                                            style: styleSKU),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: (size.width - 2*horizontalPadding)/nColumns*qtyFlex,
                                                                                    child: Text(' ${NumberFormat('#,##0').format(gbDetailedQty[thisSKU])}',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: styleSKU),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: (size.width - 2*horizontalPadding)/nColumns*valFlex,
                                                                                    child: Text(' ${NumberFormat('\$#,##0.00').format(gbDetailedValue[thisSKU])}',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: styleSKU),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: (size.width - 2*horizontalPadding)/nColumns*vpgbFlex,
                                                                                    child: Text(' ${NumberFormat('\$#,##0.00').format(thisModelValue)}',
                                                                                        textAlign: TextAlign.right,
                                                                                        style: styleSKU),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ]);
                                                                    }
                                                                  }),
                                                            ],
                                                          );
                                                          }),
                                                  ],
                                                );
                                                    }),
                                                    ]);
                                              }),
                                        ],),
                                    )
               ),
            );}
    else{
      return const Loading();
    }
    });
  }
}
