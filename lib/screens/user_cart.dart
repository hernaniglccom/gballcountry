// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/services/dbaseActivities.dart';
import 'package:gballcountry/services/dbaseUser.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:gballcountry/shared/loading.dart';
import 'package:intl/intl.dart';

import 'package:gballcountry/private_classes/warehouse.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';

class CartView extends StatefulWidget {
  final String userId;
  final LocationInformation thisLocation;
  final bool hasLocation;
  const CartView({Key? key, required this.userId, required this.thisLocation, required this.hasLocation}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double padding = pow(size.width, 1/4)*1.5;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;
    final double fontSizeText = pow(size.height, 1/2) / 1.75;
    final double containerHeightViewMode = (fontSizeTitle + padding) * 2 ;
    final double containerWidthViewMode = (size.width - 1 - padding * 6);
    Color? slideForegroundColor = Colors.lightBlue[700];
    Color? slideBackgroundColor = Colors.lightBlue[100];

    void selectLocation(){
      showModalBottomSheet(context: context, builder: (context){
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Text('This functionality has not been implemented yet. \nPlease, go back to the Home screen, select the "Warehouse" section, pick a location and click on "Store content from cart in this location".',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSizeSubtitle)),
              const DismissButton(n: 1),
            ],
          ),
        );
    });
    }

    void confirmationMessage(String itemTransferred, int n){
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
                padding: EdgeInsets.symmetric(vertical: fontSizeSubtitle),
                child: Text('Item successfully added to this location:\n $itemTransferred',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSizeSubtitle)),
              ),
              SizedBox(height: fontSizeSubtitle),
              DismissButton(n: n),
            ],
          ),
        );
      });
    }

    void transferContent(UserData thisUserData, List<dynamic> cartContent, int contentLineNumber, int quantity, int contextsToPop) async {
      var transferredContent = cartContent[contentLineNumber];
      transferredContent['Value'] = quantity * cartContent[contentLineNumber]['Value'] / cartContent[contentLineNumber]['Quantity'];
      transferredContent['Quantity'] = quantity;
      String itemTransferred = '${transferredContent['Quantity']} ${transferredContent['Line']} ${transferredContent['Brand']} ${transferredContent['Model']} ${transferredContent['Grade']}';
        if (widget.hasLocation) {
          setState(() => loading = true);
          widget.thisLocation.addContent(cartContent[contentLineNumber]);
          /// Updating Location and sending to database
          var location = widget.thisLocation;
          String intFixed(int n, int count) =>
              n.toString().padLeft(count, "0");
          String thisLocationId =
              '${location.shelfId}-${intFixed(location.positionNumber - 1, 3)}';
          await LocationDatabaseService(
              locationId: thisLocationId)
              .updateLocationData(
              thisLocationId,
              location.rackId,
              location.shelfId,
              location.shelfSerialNumber,
              location.positionNumber,
              location.locationName,
              location.locationSerialNumber,
              location.locationContent);

          /// Adding log of operation to database
          await ActivityDatabaseService(activityId: timeStampNow())
          .updateActivity(
      widget.userId,
      'from_cart_to_location',
      'user_cart',
      [cartContent[contentLineNumber]],
      thisLocationId,
      [cartContent[contentLineNumber]]);

      /// Updating User Cart and sending to database
      thisUserData.removeContent(contentLineNumber, cartContent[contentLineNumber]['Quantity']);
      await UserDatabaseService(userId: widget.userId)
          .updateUserData(thisUserData.userName, thisUserData.role, thisUserData.cartContent);
      /// add loading screen and confirmation message
        setState(() => loading = false);
          confirmationMessage(itemTransferred, contextsToPop);
      } else {
      selectLocation();
      }
    }

    Widget StoreAllAction(List<dynamic> cartContent, int index){
      return loading? const Loading() : StreamBuilder<UserData>(
          stream: UserDatabaseService(userId: widget.userId).userData,
          builder: (context, snapshot) {
      if(snapshot.hasData) {
        int quantity = snapshot.data!.cartContent[index]['Quantity'];
            return SlidableAction(
              label:'Store All',
              backgroundColor: slideBackgroundColor!,
              foregroundColor: slideForegroundColor,
              icon: Icons.store,// color: slideForegroundColor),
                onPressed:(context) async {
                  transferContent(snapshot.data!, cartContent, index, quantity, 2);
                });
      } else{
        return const Loading();
      }
          });
    }

    Widget StoreSomeAction(List<dynamic> cartContent, int index, bool loading){
      return loading? const Loading() : StreamBuilder<UserData>(
            stream: UserDatabaseService(userId: widget.userId).userData,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return SlidableAction(
                    label:'Store Some',
                    backgroundColor: slideBackgroundColor!,
                    foregroundColor: slideForegroundColor,
                    icon: Icons.store_outlined,// color: slideForegroundColor),
                    onPressed:(context){
                      showModalBottomSheet(context: context, builder: (context){
                        final controller = TextEditingController();
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(padding*3),
                              child: Text(
                                'How many golf balls would you like to store in this location?',
                                style: TextStyle(fontSize: fontSizeSubtitle),
                                textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: EdgeInsets.all(padding),
                              child: Text(
                                '${cartContent[index]['Quantity']} ${cartContent[index]['Line']} ${cartContent[index]['Brand']} ${cartContent[index]['Model']} ${cartContent[index]['Grade']}',
                                style: TextStyle(fontSize: fontSizeSubtitle),
                                textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: EdgeInsets.all(padding),
                              child: TextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(hintText: 'Type amount here'),
                                style: TextStyle(fontSize: fontSizeText),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ThousandsSeparatorInputFormatter(),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(padding*6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(padding),
                                    child: const CancelButton(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(padding),
                                    child: InkWell(
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
                                                    child: Text('Submit', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        transferContent(snapshot.data!, cartContent, index, int.parse(controller.text), 2);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      });
                    });
              } else{
                return const Loading();
              }
            });
    }

    return loading ? const Loading() : StreamBuilder<UserData>(
        stream: UserDatabaseService(userId: widget.userId).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var cartContent = snapshot.data!.cartContent;
            if (cartContent.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                        'Looks like your cart is empty.\n Please add some items to it first.',
                        style: TextStyle(fontSize: fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue[900])),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(padding * 2),
                      child: Text('Cart content',
                          style: TextStyle(fontSize: fontSizeTitle,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue[900])),
                    ),
                    Center(
                      child: Wrap(
                        children: List.generate(
                            cartContent.length,
                                (index) {
                              return Padding(
                                padding: EdgeInsets.all(padding),
                                child: Slidable(
                                    startActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: widget.hasLocation ?
                                      <Widget>[StoreAllAction(cartContent, index),
                                      StoreSomeAction(cartContent, index, false),]
                                          : <Widget>[
                                        SlidableAction(
                                          label: 'Wash',
                                          foregroundColor: slideForegroundColor,
                                          backgroundColor: slideBackgroundColor!,
                                          icon: Icons.local_laundry_service,
                                          onPressed: null,
                                        ),
                                      SlidableAction(
                                        label: 'Sort',
                                        foregroundColor: slideForegroundColor,
                                        backgroundColor: slideBackgroundColor,
                                        icon: Icons.spellcheck,
                                        onPressed: null,
                                      ),
                                      SlidableAction(
                                        label: 'Grade',
                                        foregroundColor: slideForegroundColor,
                                        backgroundColor: slideBackgroundColor,
                                        icon: Icons.star_half,
                                        onPressed: null,
                                      ),
                                    ]),
                                    child: Container(
                                      height: containerHeightViewMode,
                                      width: containerWidthViewMode,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue[700],
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),),
                                      child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Row(
                                                //mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(width: padding,
                                                    height: fontSizeTitle +
                                                        2 * padding,),
                                                  const Icon(
                                                    Icons.arrow_forward,
                                                    color: Colors.white70,
                                                  ),
                                                  Text(' ${NumberFormat('#,###')
                                                      .format(
                                                      cartContent[index]['Quantity'])} ${cartContent[index]['Line']} ${cartContent[index]['Brand']} ${cartContent[index]['Model']} ${cartContent[index]['Grade']}',
                                                      style: TextStyle(
                                                          fontSize: fontSizeText,
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .white70)),
                                                ])
                                            ])
                                      ),
                                    )
                                ),
                              );
                            }
                        ),
                      ),
                    ),
                    SizedBox(height: fontSizeTitle + 2 * padding),
                    widget.hasLocation ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CancelButton(),
                        SizedBox(width: size.width/24),
                        InkWell(
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
                                          child: const Icon(Icons.store, color: Colors.white70),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(padding),
                                          child: Text('Store all items into location', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            onTap: ()async{
                              setState(() => loading = true);
                              for(var i=0; i<cartContent.length; i++){
                                widget.thisLocation.addContent(cartContent[i]);
                              }
                              /// Updating Location and sending to database
                              var location = widget.thisLocation;
                              String intFixed(int n, int count) => n.toString().padLeft(count, "0");
                              String thisLocationId = '${location.shelfId}-${intFixed(location.positionNumber - 1, 3)}';
                              await LocationDatabaseService(
                                  locationId: thisLocationId)
                                  .updateLocationData(
                                  thisLocationId,
                                  location.rackId,
                                  location.shelfId,
                                  location.shelfSerialNumber,
                                  location.positionNumber,
                                  location.locationName,
                                  location.locationSerialNumber,
                                  location.locationContent);

                              /// Adding log of operation to database
                              await ActivityDatabaseService(activityId: timeStampNow())
                                  .updateActivity(
                                  widget.userId,
                                  'whole_cart_to_location',
                                  'user_cart',
                                  cartContent,
                                  thisLocationId,
                                  cartContent);

                              /// Updating User Cart and sending to database
                              var thisUserData = snapshot.data!;
                              String itemTransferred = '';
                              for(var i=cartContent.length-1; i>=0; i--){
                                itemTransferred = '$itemTransferred ${cartContent[i]['Quantity']} ${cartContent[i]['Line']} ${cartContent[i]['Brand']} ${cartContent[i]['Model']} ${cartContent[i]['Grade']}\n';
                                thisUserData.removeContent(i, cartContent[i]['Quantity']);
                              }
                              await UserDatabaseService(userId: widget.userId)
                                  .updateUserData(thisUserData.userName, thisUserData.role, thisUserData.cartContent);
                              /// add loading screen and confirmation message
                              setState(() => loading = false);
                              confirmationMessage('message',2);//(itemTransferred, 2);//
                            }
                        ),
                      ],
                    ) : const SizedBox.shrink(),
                  ]),
              );
            }
          } else {
            return const Loading();
          }
        });
  }
}