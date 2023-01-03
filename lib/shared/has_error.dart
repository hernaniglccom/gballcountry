import 'dart:math';
import 'package:flutter/material.dart';

class HasError extends StatelessWidget {
  const HasError({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    //final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    //final double padding = pow(size.width, 1 / 4) * 1.5;

    List<double> adjustingImage(imageWidth, imageHeight, finalWidth, finalHeight){
      if (imageHeight / finalHeight > imageWidth / finalWidth){
        imageWidth =  imageWidth * finalHeight / imageHeight;
        imageHeight = imageHeight * finalHeight / imageHeight;
      }else{
        imageHeight = imageHeight * finalWidth / imageWidth;
        imageWidth =  imageWidth * finalWidth / imageWidth;
      }
      return [imageWidth , imageHeight];
    }

    double imageHeight = 720;
    double imageWidth = 960;

    var imageDimensions = adjustingImage(imageWidth, imageHeight, size.width - 6 * horizontalPadding, size.height - 10 * verticalPadding);
    imageWidth = imageDimensions[0];
    imageHeight= imageDimensions[1];

    return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: verticalPadding),
                  Text('Something is not right...', // 'This was not intended',
                      style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold, color: Colors.lightBlue[900])),
                  SizedBox(height: verticalPadding),
                  Image(height: imageHeight, width: imageWidth,
                      image: const AssetImage('assets/images/error1.jpg')),
                ],
              ),
            ),
          ),
        );
  }
}