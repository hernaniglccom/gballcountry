import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gballcountry/private_classes/fulfilled_order.dart';
import 'package:gballcountry/screens/dev/dev_view.dart';
import 'package:gballcountry/screens/processes/register_sale/register_sale.dart';
import 'package:gballcountry/screens/processes/view_stock/rack_list.dart';
import 'package:gballcountry/services/dbaseFulfilledOrders.dart';
import 'package:gballcountry/shared/weight_table.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/private_classes/invoice.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/private_classes/vendor.dart';
import 'package:gballcountry/private_classes/warehouse.dart';

import 'package:gballcountry/screens/user_cart.dart';
import 'package:gballcountry/screens/home/users/user_list.dart';
import 'package:gballcountry/screens/processes/add_invoice/add_invoice2.dart';
import 'package:gballcountry/screens/processes/receive/invoice_list.dart';
import 'package:gballcountry/screens/processes/view_stock/blueprint_view.dart';
import 'package:gballcountry/screens/processes/view_stock/stock_summary.dart';

import 'package:gballcountry/services/auth.dart';
import 'package:gballcountry/services/dbaseVendorInvoice.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';
import 'package:gballcountry/services/dbaseUser.dart';

import 'package:gballcountry/shared/settings_form.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:gballcountry/shared/loading.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  bool viewCase0 = false;
  bool viewCase1 = false;
  bool viewCase2 = false;
  bool viewCase3 = false;
  bool viewCase4 = false;
  bool viewCase5 = false;
  bool viewCase6 = false;
  bool viewCase7 = false;
  bool viewCase8 = false;
  bool viewCart = false;
  bool viewDev = false;

  void allViewsFalse (){
    viewCase0 = false;
    viewCase1 = false;
    viewCase2 = false;
    viewCase3 = false;
    viewCase4 = false;
    viewCase5 = false;
    viewCase6 = false;
    viewCase7 = false;
    viewCase8 = false;
    viewCart = false;
    viewDev = false;
  }

  void processButtonPressed(int viewIndex) {
    switch(viewIndex){
      case 0:
        setState(() => viewCase0 = !viewCase0);
        break;
      case 1:
        setState(() => viewCase1 = !viewCase1);
        break;
      case 2:
        setState(() => viewCase2 = !viewCase2);
        break;
      case 3:
        setState(() => viewCase3 = !viewCase3);
        break;
      case 4:
        setState(() => viewCase4 = !viewCase4);
        break;
      case 5:
        setState(() => viewCase5 = !viewCase5);
        break;
      case 6:
        setState(() => viewCase6 = !viewCase6);
        break;
      case 7:
        setState(() => viewCase7 = !viewCase7);
        break;
      case 8:
        setState(() => viewCase8 = !viewCase8);
        break;
      default:
        setState(() => allViewsFalse());
        break;
    }
  }

  void _showSettingsPanel(){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      double horizontalPadding = size.width/30;
      double verticalPadding = size.height/40;
      return FractionallySizedBox(
        heightFactor: .5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding/2),
          child: const SettingsForm(),
        ),
      );
    });
  }

  void _showWeightTable(){
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){
      final Size size = MediaQuery.of(context).size;
      double horizontalPadding = size.width/30;
      double verticalPadding = size.height/40;
      return FractionallySizedBox(
        heightFactor: .9,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding/2),
          child: const WeightTable(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    //final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;

    final user = Provider.of<AppUser>(context);
    final thisUser = Provider.of<UserData?>(context);
    double sizeButton = pow(size.width, 1 / 4) * 15;

    LocationInformation testLocation = LocationInformation(rackId:'999',
        shelfId: '999-999',
        shelfSerialNumber: 999,
        positionNumber: 999,
        locationSerialNumber: 999,
        locationName: 'user has not selected a location yet',
        locationContent: [{'Quantity': 10000, 'Line': 'Pro', 'Brand': 'Callaway', 'Model': 'Mix', 'Grade': '3A', 'Value':10000.0}]
    );
    if(thisUser == null) {
      return const Loading();
    }else {
      return StreamProvider<List<UserInformation>>.value(
        value: UserDatabaseService
            .withoutUserId()
            .userInfo,
        initialData: const [],
        child: StreamProvider<List<VendorInformation>>.value(
          value: VendorDatabaseService
              .withoutVendorId()
              .vendorInfo,
          initialData: const [],
          child: StreamProvider<List<InvoiceInformation>>.value(
            value: InvoiceDatabaseService
                .withoutInvoiceId()
                .invoiceInfo,
            initialData: const [],
            child: StreamProvider<List<RackInformation>>.value(
              value: RackDatabaseService
                  .withoutRackId()
                  .rackInfo,
              initialData: const [],
              child: StreamProvider<List<ShelfInformation>>.value(
                value: ShelfDatabaseService
                    .withoutShelfId()
                    .shelfInfo,
                initialData: const [],
                child: StreamProvider<List<LocationInformation>>.value(
                  value: LocationDatabaseService
                      .withoutLocationId()
                      .locationInfo,
                  initialData: const [],
                  child: StreamProvider<List<FulfillmentInformation>>.value(
                    value: FulfillmentDatabaseService
                        .withoutOrderId()
                        .fulfillmentInfo,
                    initialData: const [],
                    child: Scaffold(
                      appBar: AppBar(
                          title: const Text('Golf Ball Country'),
                          backgroundColor: Colors.lightBlue[900],
                          elevation: 0.0,
                          actions: <Widget>[
                            Tooltip(
                              message: 'Home',
                              child: InkWell(
                                /// Home
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(
                                        Icons.home, color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() => allViewsFalse());
                                  }
                              ),
                            ),
                            Tooltip(
                              message: 'GBCart',
                              child: InkWell(
                                /// Cart
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(Icons.shopping_cart,
                                        color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      allViewsFalse();
                                      viewCart = !viewCart;
                                    });
                                  }
                              ),
                            ),
                            Tooltip(
                              message: 'Settings',
                              child: InkWell(
                                /// Settings
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(
                                        Icons.settings, color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() => _showSettingsPanel());
                                  }
                              ),
                            ),
                            Tooltip(
                              message: 'Quantity Estimator',
                              child: InkWell(
                                /// Settings
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(
                                        Icons.find_replace, color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() => _showWeightTable());
                                  }
                              ),
                            ),
                            thisUser.role == 'dev' ? Tooltip(
                              message: 'Dev Options',
                              child: InkWell(
                                /// DevView
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(
                                        Icons.code, color: Colors.white70),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      allViewsFalse();
                                      viewDev = !viewDev;
                                    });
                                  }
                              ),
                            ) : const SizedBox.shrink(),
                            Tooltip(
                              message: 'Log out',
                              child: InkWell(
                                /// Log out
                                  child: Padding(
                                    padding: EdgeInsets.all(padding * 1.5),
                                    child: const Icon(Icons.logout_rounded,
                                        color: Colors.white70),
                                  ),
                                  onTap: () async {
                                    await _auth.signOut();
                                  }
                              ),
                            ),
                          ]
                      ),
                      body: viewCase0 ? const AddInvoice2() :
                      viewCase1 ? const InvoiceList() :
                      viewCase2 ? const Loading() :
                      viewCase3 ? const BlueprintView() :
                      viewCase4 ? const Loading() :
                      viewCase5 ? const RackList() :
                      viewCase6 ? const UserList() :
                      viewCase7 ? const StockSummary() :
                      viewCase8 ? RegisterSale(user: user,
                          thisLocation: testLocation,
                          contentLineNumber: 0) : //HasError():
                      viewDev ? const DevView() :
                      viewCart ? CartView(
                          userId: user.userId,
                          //cartContent: snapshot.data!.cartContent,
                          hasLocation: false,
                          thisLocation: testLocation
                      ) :
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Row(
                                children: [
                                  //SizedBox(height: verticalPadding * 3,),
                                  SizedBox(width: size.width * 2 / 3,
                                    height: verticalPadding * 5,
                                    child: Center(
                                      child: StreamBuilder<UserData>(
                                          stream: UserDatabaseService(
                                              userId: user.userId).userData,
                                          builder: (context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                  'Hello, ${snapshot.data!
                                                      .userName}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: fontSizeTitle,
                                                      color: Colors
                                                          .lightBlue[800]));
                                            } else {
                                              return Text('Hey there!',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: fontSizeTitle,
                                                      color: Colors
                                                          .lightBlue[800]));
                                            }
                                          }
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width / 3,),
                                ],),
                            ),
                            Row(
                              children: [
                                SizedBox(width: size.width * 3 / 4,
                                  height: verticalPadding * 3 / 2,
                                  child: Center(
                                    child: Text('What do you want to do next?',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: fontSizeSubtitle,
                                            color: Colors.lightBlue[500])),
                                  ),
                                ),
                                SizedBox(width: size.width / 4,),
                              ],),
                            Row(
                              children: [
                                ProcessButton(buttonLabel: 'Add Invoice', buttonIcon: Icon(
                                    Icons.post_add_outlined, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 0),
                                ProcessButton(buttonLabel: 'Receive from Supplier', buttonIcon: Icon(
                                    Icons.local_shipping, size: sizeButton),
                                    buttonFunction:processButtonPressed,
                                    buttonIndex: 1),
                              ],),
                            /*Row(
                              children: [
                                ProcessButton(
                                    buttonLabel: 'Wash',
                                    buttonIcon: Icon(Icons.local_laundry_service, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 2),
                                ProcessButton(
                                    buttonLabel: 'Sort',
                                    buttonIcon: Icon(Icons.spellcheck, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 3),
                              ],),*/
                            Row(
                              children: [
                                ProcessButton(
                                    buttonLabel: 'View Warehouse',
                                    buttonIcon: Icon(Icons.store, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 5),
                                ProcessButton(
                                    buttonLabel: 'Summarize Stock',
                                    buttonIcon: Icon(Icons.search, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 7),
                              ],),
                            Row(
                              children: [
                                //ProcessButton(buttonLabel: 'Test: Loading Screen', Icon(Icons.star_half, size: sizeButton), processButtonPressed, 4),
                                ProcessButton(
                                    buttonLabel: 'View Team Members',
                                    buttonIcon: Icon(Icons.supervisor_account, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 6),
                              ],),
                            /*Row(
                              children: [
                                ProcessButton(
                                    buttonLabel: 'Test: Error Screen',
                                    buttonIcon: Icon(Icons.build, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 8),
                                //ProcessButton(
                                    buttonLabel: 'Extra Button 2',
                                    buttonIcon: const Icon(Icons.search, size: sizeButton),
                                    buttonFunction: processButtonPressed,
                                    buttonIndex: 7),
                              ],),
                            Row(
                                    children: [
                                      ProcessButton(buttonLabel: 'Extra Button 3',
                                          buttonIcon: const Icon(Icons.supervisor_account, size: sizeButton),
                                          buttonFunction: processButtonPressed,
                                          buttonIndex: 6),
                                      ProcessButton(buttonLabel: 'Extra Button 4',
                                          buttonIcon: const Icon(Icons.search, size: sizeButton),
                                          buttonFunction: processButtonPressed,
                                          buttonIndex: 7),
                                    ],),*/
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //),
          ),
        ),
      );
    }
  }
}