import 'package:flutter/material.dart';

class BlueprintView extends StatefulWidget {
  const BlueprintView({Key? key}) : super(key: key);

  @override
  State<BlueprintView> createState() => _BlueprintViewState();
}

class _BlueprintViewState extends State<BlueprintView> {
  bool viewEast = true;
  bool viewCenter = false;
  bool viewWest = false;
  double imageHeight = 1212;
  double imageWidth = 1180;

  void adjustingImage(finalHeight, finalWidth){
    if (imageHeight / finalHeight > imageWidth / finalWidth){
      imageWidth =  imageWidth * finalHeight / imageHeight;
      imageHeight = imageHeight * finalHeight / imageHeight;
    }else{
      imageHeight = imageHeight * finalWidth / imageWidth;
      imageWidth =  imageWidth * finalWidth / imageWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    //final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    //final double padding = pow(size.width, 1 / 4) * 1.5;

    adjustingImage(size.height,size.width);
    return Scrollbar(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: viewWest? ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[700]) :ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[800]),
                    onPressed: (() =>
                        setState (() {
                          viewEast = false;
                          viewCenter = false;
                          viewWest = true;
                        })
                    ),
                    child: const Text('West', style: TextStyle(color: Colors.white)),),
                  SizedBox(width: horizontalPadding, height: verticalPadding,),
                  ElevatedButton(
                      style: viewCenter? ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[700]) :ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[800]),
                      onPressed: (() =>
                          setState (() {
                            viewEast = false;
                            viewCenter = true;
                            viewWest = false;
                          })
                      ),
                    child: const Text('Center', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: horizontalPadding, height: verticalPadding,),
                  ElevatedButton(
                      style: viewEast? ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[700]) :ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue[800]),
                      onPressed: (() =>
                          setState (() {
                            viewEast = true;
                            viewCenter = false;
                            viewWest = false;
                          })
                      ),
                    child: const Text('East', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            SizedBox(width: horizontalPadding, height: verticalPadding,),
            Stack(
                children: <Widget>[
                  Image(height: imageHeight, width: imageWidth,
                      image: viewEast ? const AssetImage('assets/images/warehouse_cropped_east.jpg'):
                          viewCenter? const AssetImage('assets/images/warehouse_cropped_center.jpg') :
                          const AssetImage('assets/images/warehouse_cropped_west.jpg')),
                  Positioned(
                    top: 400, left:20, width: 100, height: 400,
                    child: Container(
                      width:150, height:150, color: Colors.red[400],
                      child: const Text('\n\n\n\n\n\n\n\n Rack 1', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Positioned(
                    top: 525, left:265, width: 150, height: 240,
                    child: Container(
                      width:150, height:150, color: Colors.red[400],
                      child: const Text('\n\n\n Shipping\n Station', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }
}
