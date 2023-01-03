import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gballcountry/private_classes/fulfilled_order.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/private_classes/warehouse.dart';

import 'package:gballcountry/services/dbaseActivities.dart';
import 'package:gballcountry/services/dbaseFulfilledOrders.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:gballcountry/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class RegisterSale extends StatefulWidget {
  final AppUser user;
  final LocationInformation thisLocation;
  final int contentLineNumber;
  final List<int> packageSizes = [12,24,48,50,72,100,0];
  RegisterSale({Key? key,required this.user, required this.thisLocation, required this.contentLineNumber}) : super(key: key);

  @override
  State<RegisterSale> createState() => _RegisterSaleState();
}

class _RegisterSaleState extends State<RegisterSale> {
  late Map<String, dynamic> thisContent = widget.thisLocation.locationContent[widget.contentLineNumber];
  late int availableBalls = thisContent['Quantity'];
  int totalSoldBalls = 0;
  int totalPackages = 0;
  List<int> packageSizesCustom = [];
  late Map<int,int> nbOfPackagesPerSize = {widget.packageSizes[0]:0, widget.packageSizes[1]:0, widget.packageSizes[2]:0, widget.packageSizes[3]:0, widget.packageSizes[4]:0, widget.packageSizes[5]:0, widget.packageSizes[6]:0};
  int exactAmount = 0;
  String errorText = '';
  bool loadingScreen = false;
  final List<int> quantityOptions = [1,2,3,4,5,10,15,20,25,50,100,17,22,36,44];
  late int dropdownQuantityInitialValue = quantityOptions[0];

  TextEditingController _exactAmountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _exactAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _exactAmountController.dispose();
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

    final orders = Provider.of<List<FulfillmentInformation>>(context);
    final user = Provider.of<AppUser>(context);

    void showConfirmationMessage(int totalPackages, int nbBalls){
      showModalBottomSheet(context: context, builder: (context){
        final Size size = MediaQuery.of(context).size;
        final double horizontalPadding = size.width/30;
        final double verticalPadding = size.height/40;
        final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
              child: Center(
                child: Text('You have successfully picked ${NumberFormat('#,###').format(totalPackages)} packages with a total of ${NumberFormat('#,###').format(nbBalls)} golf balls.',
                    style: TextStyle(fontSize: fontSizeSubtitle)),
              ),
            ),
            const DismissButton(n: 2),
            SizedBox(height: verticalPadding*2)
          ],
        );
      });
    }

    Widget qtyButton(int nBalls){
      if(nBalls>0) {
        return InkWell(
          onTap: () {
            setState(() {
              if(availableBalls-nBalls>=0){
                errorText = '';
                nbOfPackagesPerSize[nBalls] = nbOfPackagesPerSize[nBalls]! + 1*dropdownQuantityInitialValue;
                totalPackages += 1*dropdownQuantityInitialValue;
                totalSoldBalls += nBalls*dropdownQuantityInitialValue;
                availableBalls -= nBalls*dropdownQuantityInitialValue;
              }else{
                errorText = 'There are not enough golf balls available to pick this package.\nPlease, select a smaller size.';
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Container(
                decoration: BoxDecoration(color: Colors.lightBlue[700],
                    borderRadius: BorderRadius.all(Radius.circular(padding))),
                child: Padding(
                  padding: EdgeInsets.all(padding * 4),
                  child: Text('$nBalls', style: TextStyle(
                      fontSize: fontSizeTitle,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold),),
                )
            ),
          ),
        );
      }else{
        double textFieldContainerWidth = size.width/6*2;
        double addInkwellContainerWidth = size.width/8*2;
        double totalPaddingInOutsideContainer = padding * (1.25*2 + 2*2);
        double outsideContainerWidth = (totalPaddingInOutsideContainer + textFieldContainerWidth + addInkwellContainerWidth*1.1);
          return Padding(
            padding: EdgeInsets.all(padding), /// padding outside of container
            child: Container(
              width: outsideContainerWidth,
                decoration: BoxDecoration(color: Colors.lightBlue[700],
                    borderRadius: BorderRadius.all(Radius.circular(padding))),
                child: Padding(
                  padding: EdgeInsets.all(padding*1.25), /// padding inside of container
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Custom size:', style: TextStyle(
                          fontSize: fontSizeText,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold),),
                          SizedBox(height: padding),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: textFieldContainerWidth,
                                child: TextFormField(
                                  controller: _exactAmountController,
                                  decoration: InputDecoration(
                                      labelText: 'Type here',
                                      filled: true,
                                      fillColor: Colors.white70,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(width: 0, color: Colors.white70),
                                        borderRadius: BorderRadius.circular(padding),
                                    ),
                                  ),
                                  //validator: (v) => v!.isEmpty ? 'Enter invoice\'s date': null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  onChanged: (v){setState((){
                                    exactAmount= int.parse(v.replaceAll(RegExp('[^0-9]'), ''));});
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padding), /// padding inside container as well
                                child: InkWell(
                                  onTap: ()=> setState(() {
                                    if(availableBalls-exactAmount>=0){
                                      errorText = '';
                                      var exactAmountIsAPackageSize = false;
                                      for (var i = 0; i < packageSizesCustom.length; i++) {
                                        if (packageSizesCustom[i] == exactAmount) {
                                          exactAmountIsAPackageSize = true;
                                          nbOfPackagesPerSize[exactAmount] = nbOfPackagesPerSize[exactAmount]! + 1*dropdownQuantityInitialValue;
                                          break;
                                    }
                                  }
                                  if (!exactAmountIsAPackageSize) {
                                    packageSizesCustom.insert(packageSizesCustom.length, exactAmount);
                                    nbOfPackagesPerSize[exactAmount] = 1*dropdownQuantityInitialValue;
                                  }
                                  totalPackages += 1*dropdownQuantityInitialValue;
                                  totalSoldBalls += exactAmount*dropdownQuantityInitialValue;
                                  availableBalls -= exactAmount*dropdownQuantityInitialValue;
                                    }else{
                                      errorText = 'There are not enough golf balls available to pick this package.\nPlease, select a smaller size.';
                                    }
                            }),
                                  child: Container(
                                    height: padding*5,
                                    width: addInkwellContainerWidth,
                                    decoration: BoxDecoration(color: Colors.green,
                                        borderRadius: BorderRadius.all(Radius.circular(padding))),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add , color: Colors.white70),
                                        Text(' Add ', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ],
                  ),
                )
            ),
          );
      }
    }

    return loadingScreen ? const Loading() : Padding(
          padding: EdgeInsets.all(horizontalPadding/1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Picking ', style: TextStyle(fontSize: fontSizeSubtitle)),
                    SizedBox(
                      width: horizontalPadding*3,
                      child: DropdownButton(
                        isExpanded: true,
                        value: dropdownQuantityInitialValue, //initial value
                        icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
                        items: quantityOptions.map((int option) { // Array list of items
                          return DropdownMenuItem(value: option, child: Center(child: Text(option.toString())));
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() => dropdownQuantityInitialValue = newValue!);
                        },),
                    ),
                    dropdownQuantityInitialValue > 1 ? Text(' units from:', style: TextStyle(fontSize: fontSizeSubtitle)) : Text(' unit from:', style: TextStyle(fontSize: fontSizeSubtitle)),
                  ],
                ),
                SizedBox(height:verticalPadding/5),
                Text(' ${NumberFormat('#,###').format(thisContent['Quantity'])} ${thisContent['Line']} ${thisContent['Brand']} ${thisContent['Model']} ${thisContent['Grade']}', style: TextStyle(fontSize: fontSizeTitle)),
                SizedBox(height:verticalPadding/5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Golf balls remaining in this location: ', style: TextStyle(fontSize: fontSizeSubtitle)),
                    Text(NumberFormat('#,###').format(availableBalls), style: TextStyle(fontSize: fontSizeSubtitle)),
                  ],
                ),
                SizedBox(height:verticalPadding/5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                        children:
                        List.generate(
                            widget.packageSizes.length,
                                (index) {
                              int nBalls = widget.packageSizes[index];
                              return qtyButton(nBalls);
                            })
                        ),
                    ]),
                errorText.length>1 ? Center(child: Text(errorText, textAlign:TextAlign.center, style: TextStyle(fontSize: fontSizeText, color: Colors.red))) : const SizedBox.shrink(),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal:horizontalPadding*2),
                    child: Container(
                      height: size.height/4,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          border: Border.all(color: Colors.lightBlue[700]!),
                          borderRadius: BorderRadius.all(Radius.circular(padding))),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child:
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: (size.width-4*horizontalPadding)/4,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text('Package Size', style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),
                                          ),
                                          Container(
                                            width: (size.width-4*horizontalPadding)/4,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text('Units', style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),
                                          ),
                                          Container(
                                            width: (size.width-4*horizontalPadding)/3,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text('Nb. of Golf Balls', style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),
                                          ),
                                        ],
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: widget.packageSizes.length,
                                        itemBuilder: (context, index2) {
                                          var nbOfPackages = nbOfPackagesPerSize[widget.packageSizes[index2]];
                                          if(nbOfPackages!>0){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: (size.width- 4*horizontalPadding)/4,
                                                  padding: EdgeInsets.all(padding/2),
                                                  child: Center(child: Text(NumberFormat('#,###').format(widget.packageSizes[index2]))),
                                                ),
                                                Container(
                                                  width: (size.width-4*horizontalPadding)/4,
                                                  padding: EdgeInsets.all(padding/2),
                                                  child: Center(child: Text(NumberFormat('#,###').format(nbOfPackages))),
                                                ),
                                                Container(
                                                  width: (size.width-4*horizontalPadding)/3,
                                                  padding: EdgeInsets.all(padding/2),
                                                  child: Center(child: Text(NumberFormat('#,###').format(widget.packageSizes[index2] * nbOfPackages))),
                                                ),
                                              ],
                                            );
                                          }else{
                                            return const SizedBox.shrink();
                                          }
                                        }),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          itemCount: packageSizesCustom.length,
                                          itemBuilder: (context, index2) {
                                            var nbOfPackages = nbOfPackagesPerSize[packageSizesCustom[index2]];
                                            if(nbOfPackages!>0){
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: (size.width- 4*horizontalPadding)/4,
                                                    padding: EdgeInsets.all(padding/2),
                                                    child: Center(child: Text(NumberFormat('#,###').format(packageSizesCustom[index2]))),
                                                  ),
                                                  Container(
                                                    width: (size.width-4*horizontalPadding)/4,
                                                    padding: EdgeInsets.all(padding/2),
                                                    child: Center(child: Text(NumberFormat('#,###').format(nbOfPackages))),
                                                  ),
                                                  Container(
                                                    width: (size.width-4*horizontalPadding)/3,
                                                    padding: EdgeInsets.all(padding/2),
                                                    child: Center(child: Text(NumberFormat('#,###').format(packageSizesCustom[index2] * nbOfPackages))),
                                                  ),
                                                ],
                                              );
                                            }else{
                                              return const SizedBox.shrink();
                                            }
                                          }),
                                      SizedBox(height: verticalPadding/2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: (size.width- 4*horizontalPadding)/4,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text('Total', style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),),
                                          Container(
                                            width: (size.width-4*horizontalPadding)/4,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text(NumberFormat('#,###').format(totalPackages), style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),
                                          ),
                                          Container(
                                            width: (size.width-4*horizontalPadding)/3,
                                            padding: EdgeInsets.all(padding/2),
                                            child: Center(child: Text(NumberFormat('#,###').format(totalSoldBalls), style:TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold))),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                          ),
                        )
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        nbOfPackagesPerSize = {widget.packageSizes[0]:0, widget.packageSizes[1]:0, widget.packageSizes[2]:0, widget.packageSizes[3]:0, widget.packageSizes[4]:0, widget.packageSizes[5]:0, widget.packageSizes[6]:0};
                        packageSizesCustom = [];
                        totalSoldBalls = 0;
                        totalPackages = 0;
                        availableBalls = thisContent['Quantity'];
                        dropdownQuantityInitialValue = 1;
                      }),
                      child: Container(
                          height: verticalPadding*2,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(padding)),),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel , color: Colors.white70),
                                Text(' Clear units picked', style: TextStyle(color:Colors.white70, fontSize: fontSizeText)),
                              ],),
                          )
                      ),
                    ),
                    SizedBox(width:horizontalPadding),
                    InkWell(
                      onTap: ()async{
                        setState(() => loadingScreen = true);

                        /// Update locationContent
                        String rackId = widget.thisLocation.rackId;
                        String shelfId = widget.thisLocation.shelfId;
                        int shelfSerialNumber = widget.thisLocation.shelfSerialNumber;
                        int positionNumber = widget.thisLocation.positionNumber;
                        String locationId = '$shelfId-${intFixed(positionNumber-1, 3)}';
                        String locationName = widget.thisLocation.locationName;
                        int locationSerialNumber = widget.thisLocation.locationSerialNumber;
                        List<dynamic> locationContent = widget.thisLocation.locationContent;
                        locationContent[widget.contentLineNumber]['Value'] = thisContent['Value'] / thisContent['Quantity'] * availableBalls;
                        locationContent[widget.contentLineNumber]['Quantity'] = availableBalls;
                        await LocationDatabaseService.withoutLocationId().updateLocationData(locationId, rackId, shelfId, shelfSerialNumber, positionNumber, locationName, locationSerialNumber, locationContent);

                        /// add fulfillment order to database
                        String orderId = '${dateTodayStamp()}-${intFixed(orders.length, 6)}';
                        String userId = user.userId;
                        String fromLocation = locationId;
                        String skuLine = thisContent['Line'];
                        String skuBrand = thisContent['Brand'];
                        String skuModel = thisContent['Model'];
                        String skuGrade = thisContent['Grade'];
                        double skuValue = thisContent['Value'] / thisContent['Quantity'] * totalSoldBalls;
                        final packageList = nbOfPackagesPerSize.map((key, value) => MapEntry(key.toString(), value));
                        await FulfillmentDatabaseService.withoutOrderId().updateFulfillmentData(orderId, dateToday(), userId, fromLocation, skuLine, skuBrand, skuModel, skuGrade, packageList);

                        /// Adding log of operation to database
                        var fromContent = widget.thisLocation.locationContent[widget.contentLineNumber];
                        var soldContent = {'Quantity': totalSoldBalls,'Line': skuLine, 'Brand': skuBrand, 'Model': skuModel, 'Grade': skuGrade, 'Value': skuValue};
                        await ActivityDatabaseService(activityId: timeStampNow()).updateActivity(
                            user.userId,
                            'orders_fulfilled',
                            locationId,
                            [fromContent],
                            'sold',
                            [soldContent]);


                        setState(() => loadingScreen = false);
                        showConfirmationMessage(totalPackages, totalSoldBalls);
                      },
                      child: Container(
                          height: verticalPadding*2,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(padding)),),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.done_all , color: Colors.white70),
                                Text(' Register Sale', style: TextStyle(color:Colors.white70, fontSize: fontSizeText)),
                              ],),
                          )
                      ),
                    ),
                  ],
                ),
                SizedBox(height:verticalPadding),
              ],
          ),
        );
  }
}
