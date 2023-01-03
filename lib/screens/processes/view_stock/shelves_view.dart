import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gballcountry/private_classes/warehouse.dart';

import 'package:gballcountry/screens/processes/view_stock/location_view.dart';


class ShelvesView extends StatefulWidget {
  final int shelfNumber;
  const ShelvesView({Key? key, required this.shelfNumber}) : super(key: key);
  @override
  createState() => _ShelvesViewState();
}

class _ShelvesViewState extends State<ShelvesView> {
  int _clickedPreviously = -1;

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<AppUser>(context);
    final shelves = Provider.of<List<ShelfInformation>>(context);
    final locations = Provider.of<List<LocationInformation>>(context);

    final Size size = MediaQuery.of(context).size;
    int cells = shelves[widget.shelfNumber].locationsQuantity.toInt();
    int containersPerRow = cells; //number of locations for this shelf
    final double padding = pow(size.width, 1/4)*1.5;
    const double containerSizeHideMode = 0;
    final double containerHeightOriginal = (size.height * .5) / 3;
    final double containerWidthOriginal = (size.width - 1 - padding * (containersPerRow * 2)) / containersPerRow;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;
    //final double fontSizeText = pow(size.height, 1/2) / 1.75;

    return  SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
              children: List.generate(
                cells,
                    (index){
                      return Padding(
                  padding: EdgeInsets.all(padding),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        index != _clickedPreviously ? _clickedPreviously = index : _clickedPreviously = -1;
                      });
                    },
                    child:
                    _clickedPreviously == -1 ?
                        ///deselecting previous location
                    Container(
                      height: containerHeightOriginal,
                      width: containerWidthOriginal,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[800],
                        borderRadius: BorderRadius.all(Radius.circular(padding)),
                      ),
                      child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Text(
                                '${shelves[widget.shelfNumber].shelfName},\n Position ${locations[shelves[widget.shelfNumber].locationsList[index]].locationName}',
                              //'Test',
                                style: TextStyle(fontSize: fontSizeSubtitle, fontWeight: FontWeight.bold, color: Colors.white70)),
                          )
                      ),
                    ) : _clickedPreviously == index ?
                    /// location selected for detailed view
                    LocationView(shelfSerialNumber: widget.shelfNumber, positionNumber: index) :
                    /// hiding remaining locations for ease of view
                    Container(
                      height: containerSizeHideMode,
                      width: containerSizeHideMode,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[700],
                        borderRadius: BorderRadius.all(Radius.circular(padding),),
                      ),
                      child: const Center(child: Text('')),
                    ),
                  ),
                );}
              ),
            ),
          //),
        ],
      ),
    );
  }
}