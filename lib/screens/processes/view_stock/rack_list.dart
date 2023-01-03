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
    final racks = Provider.of<List<RackInformation>>(context);
    final shelves = Provider.of<List<ShelfInformation>>(context);
    final locations = Provider.of<List<LocationInformation>>(context);
    /*for(var i=0;i<locations.length;i+=1){
      print(locations[i].locationSerialNumber);
    }*/
    const double space = 20;

    return StreamBuilder<List<RackInformation>>(
        stream: RackDatabaseService.withoutRackId().rackInfo,
    builder: (context, AsyncSnapshot snapshot){
    if (snapshot.hasData) {
          return Column(
          children: [
            Expanded(
            child:
            ListView.builder(
                  shrinkWrap: true,
                  itemCount: (racks.length),
                  itemBuilder: (context, index){
                    panelVisibility.insert(panelVisibility.length, false);
                    return Column(
                      children: [
                        ExpansionPanelList(
                          children: [
                            ExpansionPanel(
                              headerBuilder:(buildContext, context){
                                return Padding(
                                    padding: const EdgeInsets.fromLTRB(space, space, space, space),
                                    child: Text(
                                      racks[index].rackName,//'Rack $index',
                                      style: const TextStyle(fontSize: 22),)
                                );
                                },
                              body: StreamProvider<List<UserInformation>>.value(
                                value: UserDatabaseService.withoutUserId().userInfo,
                                initialData: const [],
                                child: StreamProvider<List<ShelfInformation>>.value(
                                value: ShelfDatabaseService.withoutShelfId().shelfInfo,
                                initialData: shelves,
                                  child: StreamProvider<List<LocationInformation>>.value(
                                    value: LocationDatabaseService.withoutLocationId().locationInfo,
                                    initialData: locations,
                                    child: ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          reverse: true,
                                          itemCount: racks[index].shelvesQuantity.toInt(),///number of shelves in this rack
                                          itemBuilder: (context, index2) {
                                            //print('Rack: ${racks[index]}, Shelf: $index2');
                                            return ShelvesView(shelfNumber: racks[index].shelvesList[index2]);//index2 == 0 ? 'Rack ${index+1},\n Ground level' : 'Rack ${index+1},\n Shelf #$index2');// se shelf corresponde ao rack, criar shelf, else sizedbox.shrink
                                          }),
                                     ),
                                ),
                              ),
                                        //const SizedBox(height: space,)
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
                        ),
                      ],
                    );
                  }),
            ),
          ],
        );}
    else{
      return const Loading();
    }
        }
        );
  }
}
