import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gballcountry/private_classes/invoice.dart';
import 'package:gballcountry/services/dbaseVendorInvoice.dart';
import 'package:gballcountry/shared/constants.dart';
import 'package:provider/provider.dart';

class DevView extends StatefulWidget {
  const DevView({Key? key}) : super(key: key);

  @override
  State<DevView> createState() => _DevViewState();
}

class _DevViewState extends State<DevView> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    final invoices = Provider.of<List<InvoiceInformation>>(context);
    bool view = true;

    return view ? const SizedBox.shrink() : SingleChildScrollView(
      child:Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt, size: fontSizeSubtitle,),
                          Text(' Restore Invoices to Original Content', style: TextStyle(fontSize: fontSizeSubtitle),),
                        ],),
                    ),
              onTap:()async{
                    showModalBottomSheet(context: context, builder: (context){
                      final Size size = MediaQuery.of(context).size;
                      double horizontalPadding = size.width / 30;
                      double verticalPadding = size.height / 40;

                      return Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Are you sure you want to restore all invoices current content to their original content?',
                                  style:TextStyle(fontSize: fontSizeSubtitle)),
                              SizedBox(height: verticalPadding,),
                              Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CancelButton(),
                                    SizedBox(width: horizontalPadding,),
                                    InkWell(
                                      child: Container(
                                          width: size.width/3.3,
                                          decoration: BoxDecoration(color: Colors.green[700],
                                            borderRadius: const BorderRadius.all(Radius.circular(5)),),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(padding),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(padding/4),
                                                    child: const Icon(Icons.done, color: Colors.white70),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(padding),
                                                    child: Text('Confirm', style: TextStyle(fontSize: fontSizeText, color: Colors.white70)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                      ),
                                      onTap:()async{
                                        for(var i=0;i<invoices.length;i+=1){
                                          InvoiceDatabaseService(invoiceId: intFixed(i,3)).updateInvoiceData(intFixed(i,3), invoices[i].vendorName, invoices[i].invoiceName, invoices[i].invoiceSerialNumber, invoices[i].invoiceOriginalContent, invoices[i].invoiceOriginalContent);
                                        }
                                        Navigator.pop(context);
                                      },
                                    )
                                  ]),
                              SizedBox(height: verticalPadding*2)
                            ]),
                      );
                    });
                    },
            ),
          ],
        ),
      )
    );
  }
}
