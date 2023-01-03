import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/private_classes/warehouse.dart';

import 'package:gballcountry/screens/processes/view_stock/shelves_view.dart';
import 'package:gballcountry/services/dbaseUser.dart';
import 'package:gballcountry/services/dbaseRackShelfLocation.dart';
import 'package:gballcountry/shared/loading.dart';

class RackList extends StatefulWidget {
  const RackList({Key? key}) : super(key: key);

  @override
  State<RackList> createState() => _RackListState();
}

class _RackListState extends State<RackList> {
  List<bool> panelVisibility = [false];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    //final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    const double space = 20;

    final racks = Provider.of<List<RackInformation>>(context);
    final shelves = Provider.of<List<ShelfInformation>>(context);
    final locations = Provider.of<List<LocationInformation>>(context);

    void showShelf(int index){
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){

        return StreamProvider<List<UserInformation>>.value(
            value: UserDatabaseService.withoutUserId().userInfo,
            initialData: const [],
            child: StreamProvider<List<ShelfInformation>>.value(
                value: ShelfDatabaseService.withoutShelfId().shelfInfo,
                initialData: shelves,
                child: StreamProvider<List<LocationInformation>>.value(
                    value: LocationDatabaseService.withoutLocationId().locationInfo,
                    initialData: locations,
                    child:SizedBox(
                      //padding: EdgeInsets.all(padding),
                      height: size.height*.8,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Padding(
                                padding: EdgeInsets.only(top: verticalPadding),
                                child: Row(
                                  children: [
                                    SizedBox(width: size.width*.15,),
                                    SizedBox(
                                      width: size.width*.7,
                                      child: Text(
                                        'Viewing ${racks[index].rackName}',//'Rack $index',
                                        style: TextStyle(fontSize: fontSizeTitle), textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(width:size.width*.15, child: const CloseButton()),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(verticalPadding),
                              child: Text(
                                'Select a location below to view its content:',//'Rack $index',
                                style: TextStyle(fontSize: fontSizeSubtitle),),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                reverse: true,
                                itemCount: racks[index].shelvesQuantity.toInt(),///number of shelves in this rack
                                itemBuilder: (context, index2) {
                                  return ShelvesView(shelfNumber: racks[index].shelvesList[index2]);//index2 == 0 ? 'Rack ${index+1},\n Ground level' : 'Rack ${index+1},\n Shelf #$index2');// se shelf corresponde ao rack, criar shelf, else sizedbox.shrink
                                }),
                          ],),
                      ),
                    )
                )
            )
        );
      });
    }
    //RackDatabaseService.withoutRackId().updateRackData('001', 0, '2nd Rack', 0, []);

    return StreamBuilder<List<RackInformation>>(
        stream: RackDatabaseService.withoutRackId().rackInfo,
        builder: (context, AsyncSnapshot snapshot){
          if (snapshot.hasData) {
            return  Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: verticalPadding),
                  child: Text(
                    'Viewing all racks',//'Rack $index',
                    style: TextStyle(fontSize: fontSizeTitle),),
                ),
                Padding(
                  padding: EdgeInsets.all(verticalPadding),
                  child: Text(
                    'Select a rack below to view its content:',//'Rack $index',
                    style: TextStyle(fontSize: fontSizeSubtitle),),
                ),
          Expanded(
          child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ((racks.length~/2) < 1 ? 1 : (racks.length~/2)),
                        itemBuilder: (context, index){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              racks.length <= index*3 ? const SizedBox.shrink() : Padding(
                                padding: EdgeInsets.all(padding),
                                child: InkWell(
                                  child: Container(
                                    width: size.width/3 - 6*padding,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(padding)), color: Colors.lightBlue[900]),
                                      padding: const EdgeInsets.all(space),
                                      child: Center(
                                        child: Text(
                                          racks[index*3].rackName,//'Rack $index',
                                          style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70),
                                        textAlign: TextAlign.center,),
                                      )
                                  ),
                                  onTap: () {
                                    showShelf(index * 3);
                                  },
                                ),
                              ),
                              racks.length <= index*3+1 ? const SizedBox.shrink() : Padding(
                                padding: EdgeInsets.all(padding),
                                child: InkWell(
                                  child: Container(
                                      width: size.width/3-6*padding,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(padding)), color: Colors.lightBlue[900]),
                                      padding: const EdgeInsets.all(space),
                                      child: Center(
                                        child: Text(
                                          racks[index*3+1].rackName,//'Rack $index',
                                          style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70),
                                          textAlign: TextAlign.center,),
                                      )
                                  ),
                                  onTap: () {
                                    showShelf(index * 3 + 1);
                                  },
                                ),
                              ),
                              racks.length <= index*3+2 ? const SizedBox.shrink() : Padding(
                                padding: EdgeInsets.all(padding),
                                child: InkWell(
                                  child: Container(
                                      width: size.width/3-6*padding,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(padding)), color: Colors.lightBlue[900]),
                                      padding: const EdgeInsets.all(space),
                                      child: Center(
                                        child: Text(
                                          racks[index*3+2].rackName,//'Rack $index',
                                          style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70),
                                          textAlign: TextAlign.center,),
                                      )
                                  ),
                                  onTap: () {
                                    showShelf(index * 3 + 2);
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
              ),
              ]);
          }
          else{
            return const Loading();
          }
        }
    );
  }
}
