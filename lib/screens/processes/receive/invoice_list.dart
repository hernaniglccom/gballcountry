import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/services/dbaseActivities.dart';
import 'package:gballcountry/services/dbaseUser.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:gballcountry/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/private_classes/invoice.dart';

import 'package:gballcountry/services/dbaseVendorInvoice.dart';

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  List<bool> panelVisibility = [false];
  //bool invoicePickedForReceival = false;
  InvoiceInformation? invoicePicked;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;

    final user = Provider.of<AppUser>(context);
    final invoices = Provider.of<List<InvoiceInformation>>(context);
    int quantityPicked = 0;

    void selectionError(int availability){
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

    void selectionConfirmation(String selection){
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

    void selectionPickQuantity(InvoiceInformation invoice, int contentNumber, AppUser user){
      var contentLine = invoice.invoiceCurrentContent[contentNumber];
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

        return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                  child: SizedBox(
                    height: size.height/3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('How many golf balls would you like to add to your cart?\n $selection',
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
                                child: Text('Only ', style: TextStyle(fontSize: fontSizeText),)),
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
                        SizedBox(height:verticalPadding/2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(padding),
                              child: const CancelButton(),
                            ),
                            Padding(
                              padding: EdgeInsets.all(padding),
                              child: StreamBuilder<UserData>(
                                  stream: UserDatabaseService(userId: user.userId).userData,
                                  builder: (context, snapshot){
                                    if (snapshot.hasData) {
                                      return InkWell(
                                        onTap: () async {
                                          /// Updating User Cart and sending to database
                                          pickInFull ? quantityPicked = contentLine['Quantity'] : quantityPicked = int.parse(controller.text);
                                          if(quantityPicked > contentLine['Quantity']){
                                            selectionError(contentLine['Quantity']);
                                          }else{
                                            var thisUser = snapshot.data!;
                                            Map<String, dynamic> contentAdded = {'Quantity': quantityPicked, 'Value': (quantityPicked*contentLine['Value']/contentLine['Quantity']), 'Line': contentLine['Line'], 'Brand': contentLine['Brand'], 'Model': contentLine['Model'], 'Grade': contentLine['Grade']};
                                            thisUser.addContent(contentAdded);
                                            await UserDatabaseService(userId: user.userId).updateUserData(thisUser.userName, thisUser.role, thisUser.cartContent);

                                            /// Adding log of operation to database
                                            await ActivityDatabaseService(activityId: timeStampNow()).updateActivity(
                                                user.userId,
                                                'from_invoice_to_cart',
                                                invoice.invoiceName,
                                                [contentLine],
                                                'user_cart',
                                                [contentAdded]);

                                            /// Updating Location and sending to database
                                            invoice.removeContent(contentNumber, quantityPicked);
                                            String invoiceId = intFixed(invoice.invoiceSerialNumber, 3);
                                            await InvoiceDatabaseService(invoiceId: invoiceId).updateInvoiceData(invoiceId, invoice.vendorName, invoice.invoiceName, invoice.invoiceSerialNumber, invoice.invoiceCurrentContent, invoice.invoiceOriginalContent);
                                            selection = '${NumberFormat('#,###').format(quantityPicked)} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}';
                                            selectionConfirmation(selection);
                                          }
                                          setState((){});
                                        },
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
                  ),
                );
              });
      });
    }

    void selectionPickAll(InvoiceInformation invoice, AppUser user, bool pickConfirmed){
      showModalBottomSheet(context: context, builder: (context){
        final Size size = MediaQuery.of(context).size;
        final double horizontalPadding = size.width / 30;
        final double verticalPadding = size.height / 40;
        final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
        String selection = '';
        int nbOfRuns = 0; /// variable added to ensure 'selection' is not getting double content

        return StreamBuilder<UserData>(
            stream: UserDatabaseService(userId: user.userId).userData,
            builder: (context, snapshot) {
              if(pickConfirmed){
                if (snapshot.hasData){
                  if(nbOfRuns==0){
                    var thisUser = snapshot.data!;
                    for(var i=invoice.invoiceCurrentContent.length-1; i>=0; i-=1){
                      var contentLine = invoice.invoiceCurrentContent[i];
                      selection = '$selection ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}\n';
                      thisUser.addContent(contentLine);
                      invoice.removeContent(i, contentLine['Quantity']);
                    }
                    String invoiceId = intFixed(invoice.invoiceSerialNumber, 3);
                    InvoiceDatabaseService(invoiceId: invoiceId).updateInvoiceData(invoiceId, invoice.vendorName, invoice.invoiceName, invoice.invoiceSerialNumber, invoice.invoiceCurrentContent, invoice.invoiceOriginalContent);
                    UserDatabaseService(userId: user.userId).updateUserData(thisUser.userName, thisUser.role, thisUser.cartContent);

                    ActivityDatabaseService(activityId: timeStampNow()).updateActivity(
                        user.userId,
                        'from_invoice_to_cart',
                        invoice.invoiceName,
                        invoice.invoiceOriginalContent,
                        'user_cart',
                        invoice.invoiceOriginalContent);
                    nbOfRuns+=1;
                  }
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        Text('Items successfully added to your cart:\n $selection',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: fontSizeSubtitle)),
                        const DismissButton(n: 1),
                      ],
                    ),
                  );
                } else {
                  return const Loading();
                }
              }else{
                if(nbOfRuns==0){
                  for(var i=0; i<invoice.invoiceCurrentContent.length; i+=1){
                    var contentLine = invoice.invoiceCurrentContent[i];
                    selection = '$selection ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}\n';
                  }
                  nbOfRuns +=1; /// ensuring loop above runs only once per time selectionPickAll is called
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
                             selectionPickAll(invoice, user, true);
                           }),
                     ],
                   ),
                 ],
               );
              }
            });
      });
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: invoices.length,
            itemBuilder: (context, index){
              panelVisibility.insert(panelVisibility.length, false);
              var thisInvoice = invoices[index];
              if(thisInvoice.invoiceCurrentContent.isEmpty){
                return const SizedBox.shrink();
              }else{
                return ExpansionPanelList(
                  children: [
                    ExpansionPanel(
                      headerBuilder:(context, isExpanded){
                        return Padding(
                            padding: EdgeInsets.all(padding),
                            child: Text(thisInvoice.invoiceName, style: TextStyle(fontSize: fontSizeSubtitle),)
                        );
                      },
                      body: Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: thisInvoice.invoiceCurrentContent.length,
                              itemBuilder: (BuildContext context, int index2) {
                                var contentLine = thisInvoice.invoiceCurrentContent[index2];
                                return InkWell(
                                    onTap: () {
                                      selectionPickQuantity(
                                          thisInvoice,
                                          index2,
                                          user);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_shopping_cart, color: Colors.lightBlue[700]),
                                          Text(' ${NumberFormat('#,###').format(contentLine['Quantity'])} ${contentLine['Line']} ${contentLine['Brand']} ${contentLine['Model']} ${contentLine['Grade']}',
                                              style: TextStyle(fontSize: fontSizeText)),//, color: Colors.lightBlue[700])),
                                        ],
                                      ),
                                    ),
                                  );
                              }),
                          InkWell(
                            onTap: () {
                              selectionPickAll(thisInvoice, user, false);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: Row(
                                children: [
                                  Icon(Icons.add_shopping_cart, color: Colors.lightBlue[700],),
                                  Text(' Add all items from this location to the cart',
                                      style: TextStyle(fontSize: fontSizeText)),//, color: Colors.lightBlue[700])),
                                ],
                              ),
                            ),
                          ),
                          /*InkWell(
                            onTap:(){
                              //_showCart(user, thisLocation);
                              setState(() {});
                            },
                            child:Padding(
                              padding: EdgeInsets.all(padding),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.lightBlue[700]),
                                  Text(' Store content from cart in this location',
                                      style: TextStyle(fontSize: fontSizeText)),//, color: Colors.lightBlue[700])),
                                ],
                              ),
                            ),
                          )*/
                        ],
                      ),
                      isExpanded: panelVisibility[index],
                      canTapOnHeader: true,
                    ),
                  ],
                  dividerColor: Colors.grey,
                  expansionCallback: (panelIndex, isExpanded) {
                    panelVisibility[index] = !panelVisibility[index];
                    setState(() {
                    });
                  },
                );}
            }
        ),
      ),
    );
  }
}
