import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gballcountry/private_classes/fulfilled_order.dart';
import 'package:gballcountry/screens/processes/register_sale/register_sale.dart';
import 'package:gballcountry/screens/user_cart.dart';
import 'package:gballcountry/services/dbaseActivities.dart';
import 'package:gballcountry/services/dbaseFulfilledOrders.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gballcountry/private_classes/warehouse.dart';
import 'package:gballcountry/services/dbaseUser.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/shared/loading.dart';

class LocationView extends StatefulWidget {
  final int shelfSerialNumber;
  final int positionNumber;
  const LocationView({Key? key, required this.shelfSerialNumber, required this.positionNumber}) : super(key: key);

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {

  int quantityPicked = 0;

  void _selectionPickQuantity(LocationInformation location, int locationPosition, int contentLineNumber, AppUser user){
    var contentLine = location.locationContent[contentLineNumber];
    bool pickInFull = true;
    final controller = TextEditingController();
    String selection = '${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}';
    String selectionSKU = ' ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}';

    showModalBottomSheet(context: context, builder: (context) {
      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width / 30;
      final double verticalPadding = size.height / 40;
      //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
      final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
      final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
      final double padding = pow(size.width, 1 / 4) * 1.5;

      Color getColor(Set<MaterialState> states) {
        const Set<MaterialState> interactiveStates = <MaterialState>{
          MaterialState.pressed,
          MaterialState.hovered,
          MaterialState.focused,
        };
        return states.any(interactiveStates.contains) ? Colors.green : Colors.blue;
      }

      return FractionallySizedBox(
        heightFactor: .75,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Column(
                  children: [
                    Text('How many golf balls would you like to add to your cart?\n\n Total available: $selection',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontSizeSubtitle)),
                    SizedBox(height:verticalPadding),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Checkbox(
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: pickInFull, //pickPartially
                            onChanged: (bool? v) {
                              setModalState(() {
                                pickInFull = v!;
                              });
                            },),
                        ),
                        Flexible(flex: 10,
                            child: Text('All ${NumberFormat('#,###').format(contentLine['Quantity'])}', style: TextStyle(fontSize: fontSizeText),)),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Checkbox(
                            checkColor: Colors.white,
                            fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: !pickInFull,
                            onChanged: (bool? v) {
                              setModalState(() {
                                pickInFull = !v!;
                              });
                            },),
                        ),
                        Flexible(flex: 2,
                            child: Text('Only ',
                              style: TextStyle(fontSize: fontSizeText),)),
                        //SizedBox(width: padding),
                        Flexible(
                          flex: 3,
                          child: TextField(
                            enabled: !pickInFull,
                            controller: controller,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(hintText: "this amount", ),
                            style: TextStyle(fontSize: fontSizeText*.9),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                              ThousandsSeparatorInputFormatter(),
                            ],
                          ),
                        ),
                        Flexible(flex: 6,
                            child: Text(selectionSKU, style: TextStyle(fontSize: fontSizeText),)),
                      ],
                    ),
                    SizedBox(height:verticalPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CancelButton(),
                        Padding(
                          padding: EdgeInsets.all(padding),
                          child: StreamBuilder<UserData>(
                            stream: UserDatabaseService(userId: user.userId).userData,
                            builder: (context, snapshot){
                              if (snapshot.hasData) {
                                  return
                                    InkWell(
                                        onTap: ()  async {
                                          /// Updating User Cart and sending to database
                                          pickInFull ? quantityPicked = contentLine['Quantity'] : quantityPicked = int.parse(controller.text);
                                          if (quantityPicked > contentLine['Quantity']) {
                                            _selectionError(contentLine['Quantity']);
                                          } else {
                                            var thisUser = snapshot.data!;
                                            Map<String, dynamic> contentAdded = {
                                              'Quantity': quantityPicked,
                                              'Value': (quantityPicked * contentLine['Value'] / contentLine['Quantity']),
                                              'Line': contentLine['Line'],
                                              'Brand': contentLine['Brand'],
                                              'Model': contentLine['Model'],
                                              'Grade': contentLine['Grade']
                                            };
                                            thisUser.addContent(contentAdded);
                                            await UserDatabaseService(userId: user.userId).updateUserData(thisUser.userName, thisUser.role, thisUser.cartContent);

                                            /// Adding log of operation to database
                                            String thisLocationId = '${location.shelfId}-${intFixed(locationPosition, 3)}';
                                            await ActivityDatabaseService(activityId: timeStampNow()).updateActivity(
                                                user.userId,
                                                'from_location_to_cart',
                                                thisLocationId,
                                                [contentLine],
                                                'user_cart',
                                                [contentAdded]);

                                            /// Updating Location and sending to database
                                            location.removeContent(contentLineNumber, quantityPicked);
                                            await LocationDatabaseService(locationId: thisLocationId).updateLocationData(
                                                thisLocationId,
                                                location.rackId,
                                                location.shelfId,
                                                location.shelfSerialNumber,
                                                location.positionNumber,
                                                location.locationName,
                                                location.locationSerialNumber,
                                                location.locationContent);

                                            selection = '${NumberFormat('#,###').format(quantityPicked)} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}';
                                            _selectionConfirmation(selection);
                                          }
                                        },
                                        child: Container(
                                    width: size.width/3.3,
                                        decoration: BoxDecoration(color: Colors.green,
                                          borderRadius: BorderRadius.all(Radius.circular(padding)),),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(padding),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(padding/4),
                                                  child: const Icon(Icons.add_shopping_cart, color: Colors.white70),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(padding),
                                                  child: Text('Transfer to Cart', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    ),
                                        );
                                } else {
                                  return const Loading();
                                }
                            }
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
      );
    });
  }

  void _selectionPickAll(LocationInformation location, int locationPosition, AppUser user, bool pickConfirmed){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width / 30;
      final double verticalPadding = size.height / 40;
      final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
      final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
      final double padding = pow(size.width, 1 / 4) * 1.5;
      String selection = '';
      int nbOfRuns = 0; /// variable added to ensure 'selection' is not getting double content

      return StreamBuilder<UserData>(
          stream: UserDatabaseService(userId: user.userId).userData,
          builder: (context, snapshot) {
            if(pickConfirmed){
              if (snapshot.hasData) {
                if(nbOfRuns==0){
                  nbOfRuns += 1;
                  List<Map<String, dynamic>> contentAdded = [];
                      var thisUser = snapshot.data!;
                      for (var i = location.locationContent.length-1; i >= 0 ; i -= 1) {
                        var contentLine = location.locationContent[i];
                        contentAdded.insert(contentAdded.length, contentLine);
                        selection = '$selection ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}\n';
                        thisUser.addContent(contentLine);
                        location.removeContent(i, contentLine['Quantity']);
                      }
                  String thisLocationId = '${location.shelfId}-${intFixed(locationPosition, 3)}';
                  LocationDatabaseService(locationId: thisLocationId)
                      .updateLocationData(
                      thisLocationId,
                      location.rackId,
                      location.shelfId,
                      location.shelfSerialNumber,
                      location.positionNumber,
                      location.locationName,
                      location.locationSerialNumber,
                      location.locationContent);
                  UserDatabaseService(userId: user.userId).updateUserData(thisUser.userName, thisUser.role, thisUser.cartContent);
                  ActivityDatabaseService(activityId: timeStampNow()).updateActivity(user.userId, 'from_location_to_cart', thisLocationId, contentAdded, 'user_cart', contentAdded);
                    }
                    return Container(
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Text(
                          'Items successfully added to your cart:\n $selection',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: fontSizeSubtitle)),
                      const DismissButton(n: 1),
                    ],
                  ),
                );
              }else {
                return const Loading();
              }
            } else{
              if(nbOfRuns==0){
                for(var i=0; i < location.locationContent.length; i += 1){
                  var contentLine = location.locationContent[i];
                  selection = '$selection ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}\n';
                }
                nbOfRuns +=1; /// ensuring loop above runs only once per time _selectionPickAll is called
              }
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                    child: Text('Are you sure you want to add all items below to your cart? \n\n $selection',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontSizeSubtitle)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          child: Container(
                              decoration: BoxDecoration(color: Colors.red[700],
                                borderRadius: const BorderRadius.all(Radius.circular(5)),),
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Row(
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
                              )),
                          onTap: () => Navigator.pop(context)),
                      SizedBox(width:horizontalPadding),
                      InkWell(
                          child: Container(
                              decoration: const BoxDecoration(color: Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(5)),),
                              child: Padding(
                                padding: EdgeInsets.all(padding),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(padding/4),
                                      child: const Icon(Icons.check, color: Colors.white70),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Text('Confirm', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                    )
                                  ],
                                ),
                              )),
                          onTap: () {
                            Navigator.pop(context);
                            _selectionPickAll(location, locationPosition, user, true);
                          }),
                    ],
                  ),
                ],
              );
            }
            });
    });
  }

  void _selectionConfirmation(String selection){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width/30;
      final double verticalPadding = size.height/40;
      final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;

      return Container(
        padding: EdgeInsets.symmetric(vertical: 2*verticalPadding, horizontal: horizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Item successfully added to your cart:\n $selection',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSizeSubtitle)),
            ),
            const SizedBox(height:8),
            const DismissButton(n: 2),
          ],
        ),
      );
    });
  }

  void _selectionError(int availability){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width/30;
      final double verticalPadding = size.height/40;
      final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;

      return Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Text('There are only $availability golf balls available. \n You must specify a smaller amount.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSizeSubtitle)),
      );
    });
  }

  void _showCart(AppUser user, LocationInformation thisLocation){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){

      return FractionallySizedBox(
        heightFactor: .75,
        child: CartView(userId: user.userId, thisLocation: thisLocation,  hasLocation: true));
    });
  }

  void _registerSale(AppUser user, LocationInformation thisLocation, int contentLineNumber){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){

      return StreamProvider<List<FulfillmentInformation>>.value(
          value: FulfillmentDatabaseService.withoutOrderId().fulfillmentInfo,
          initialData: const [],
          child: RegisterSale(user: user, thisLocation: thisLocation, contentLineNumber: contentLineNumber));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    //final double containerHeightViewMode = min((size.height - 1 - padding * (1 * 2))/2,(size.width - 1 - padding * (1 * 2)));
    final double containerWidthViewMode = (size.width - 1 - padding * (1 * 2));

    final user = Provider.of<AppUser>(context);
    final shelves = Provider.of<List<ShelfInformation>>(context);
    var thisShelf = shelves[widget.shelfSerialNumber];
    final locations = Provider.of<List<LocationInformation>>(context);
    var thisLocation = locations[thisShelf.locationsList[widget.positionNumber]];
    List<bool> contentExpanded = [];
    

    return Container(
      //height: containerHeightViewMode,
      width: containerWidthViewMode,
      decoration: BoxDecoration(
        color: Colors.lightBlue[700],
        borderRadius: BorderRadius.all(Radius.circular(padding)),
      ),
      child: SingleChildScrollView(
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(padding*2),
                  child: Text('\n Content of ${thisShelf.shelfName}, Position ${thisLocation.locationName}:',
                      style: TextStyle(fontSize: fontSizeSubtitle*1.3, fontWeight: FontWeight.bold, color: Colors.white70)),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: thisLocation.locationContent.length,
                    itemBuilder: (context, index2){
                      contentExpanded.insert(index2, false);
                      var contentLine = thisLocation.locationContent[index2];
                      return  Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding*12, vertical: padding),
                        child: Container(
                          decoration: BoxDecoration(color:Colors.white70, borderRadius: BorderRadius.all(Radius.circular(padding))),
                          child: Padding(
                            padding: EdgeInsets.all(padding*1.25),
                            child: Column(
                              children: [
                                Text(' ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}',
                                    style: TextStyle(fontSize: fontSizeText, fontWeight: FontWeight.bold, color: Colors.lightBlue[700])),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                              onTap: () {
                                                _selectionPickQuantity(
                                                    thisLocation,
                                                    widget.positionNumber,
                                                    index2,
                                                    user);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(top: padding*2),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.add_shopping_cart, color: Colors.lightBlue[700]),
                                                    Text(' Add to cart',
                                                        style: TextStyle(fontSize: fontSizeText, color: Colors.lightBlue[700])),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    SizedBox(width: padding*8),
                                    InkWell(
                                      onTap: () {
                                        _registerSale(user, thisLocation, index2);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(top: padding*2),
                                        child: Row(
                                          children: [
                                            Icon(Icons.inventory, color: Colors.lightBlue[700],),
                                            Text(' Fulfill order',
                                                style: TextStyle(fontSize: fontSizeText, color: Colors.lightBlue[700])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: padding)
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                SizedBox(height: padding),
                InkWell(
                  onTap: () {
                    _selectionPickAll(thisLocation, widget.positionNumber, user, false);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, color: Colors.white70, size: fontSizeText*1.5),
                        Text(' Add all items from this location to the cart',
                            style: TextStyle(fontSize: fontSizeText*1.2, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap:(){
                    _showCart(user, thisLocation);
                    setState(() {});
                  },
                  child:Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white70, size: fontSizeText*1.5),
                        Text(' Store content from cart in this location',
                            style: TextStyle(fontSize: fontSizeText*1.2, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: padding*3),
              ],
            )
        ),
      ),
    );
  }
}
