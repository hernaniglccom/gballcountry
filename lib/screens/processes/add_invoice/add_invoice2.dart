import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'package:gballcountry/private_classes/invoice.dart';
import 'package:gballcountry/private_classes/user.dart';
import 'package:gballcountry/private_classes/vendor.dart';
import 'package:gballcountry/screens/processes/view_stock/golfballsdetailed.dart';
import 'package:gballcountry/services/dbaseActivities.dart';
import 'package:gballcountry/services/dbaseVendorInvoice.dart';

import 'package:gballcountry/shared/constants.dart';
import 'package:gballcountry/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddInvoice2 extends StatefulWidget {
  const AddInvoice2({Key? key}) : super(key: key);
  @override
  createState() => _AddInvoice2State();
}

class _AddInvoice2State extends State<AddInvoice2> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  static String errorOnForm = '';

  TextEditingController _vendorNameController = TextEditingController();
  TextEditingController _invoiceDateController = TextEditingController();
  static String vendorName = 'Johnson Golf Company';
  static String invoiceDate = dateToday();
  static List<String> productLineList = [gbLineListDetailed[0]];
  static List<String> productBrandList = [gbLineBrandMapDetailed[gbLineListDetailed[0]]![0]];
  static List<String> productModelList = [gbBrandModelMapDetailed['${productLineList[0]} ${productBrandList[0]}']![0]];
  static List<String> productGradeList = [gbGradeListDetailed[0]];
  static List<String> productQuantityList = [''];
  static List<String> productCostList = [''];
  //double freightPrice = 0;

  void _showConfirmationMessage(String vendor, String nbBalls, String invoiceAmount){
    showModalBottomSheet(context: context, builder: (context){
      final Size size = MediaQuery.of(context).size;
      final double horizontalPadding = size.width/30;
      final double verticalPadding = size.height/40;
      final double fontSizeSubtitle = pow(size.height, 1/2) / 1.5;

      return Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        child: Column(
            children: [
              Text('Invoice from $vendor added successfully. \n Total of $invoiceAmount for $nbBalls golf balls.',
                  style: TextStyle(fontSize: fontSizeSubtitle)),
              Padding(
                padding: EdgeInsets.all(verticalPadding),
                child: const DismissButton(n: 1),
              ),
            ],
          ),
      );
    });
  }
  String dropdownVendorInitialValue = 'Johnson Golf Company';

  @override
  void initState() {
    super.initState();
    _vendorNameController = TextEditingController();
    _invoiceDateController = TextEditingController();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _invoiceDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    final double containerWidth = (size.width - padding*4 - horizontalPadding/2)/2;

    final invoices = Provider.of<List<InvoiceInformation>>(context);
    final vendors = Provider.of<List<VendorInformation>>(context);
    final user = Provider.of<AppUser>(context);
    //final userInfo = Provider.of<UserInformation>(context);
    List<String> vendorNameList = [];
    for(var i=0;i<vendors.length;i+=1){
      vendorNameList.insert(i, vendors[i].vendorName);
    }

    var styleInvoiceHeaders = TextStyle(fontSize: fontSizeText, color: Colors.black38);
    var styleInvoiceValues = TextStyle(fontSize: fontSizeSubtitle, color: Colors.lightBlue[700]);
    int golfBallsTotal = 0;
    double invoiceTotal = 0;
    for(var i=0;i<productCostList.length;i+=1){
      productQuantityList[i] == '' ? golfBallsTotal += 0 : golfBallsTotal += int.parse(productQuantityList[i]);
      productCostList[i] == '' ? invoiceTotal += 0 : invoiceTotal += double.parse(productCostList[i]);
    }

    return loading ? const Loading() : Center(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(padding*2),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width:containerWidth, child: const Text('Vendor')),
                          ],
                        ),
                      SizedBox(
                        width: containerWidth*1,
                        child: DropdownButton(
                          isExpanded: true,
                          value: dropdownVendorInitialValue, //initial value
                          icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
                          items: vendorNameList.map((String option) { // Array list of items
                            return DropdownMenuItem(value: option, child: Text(option));
                          }).toList(),
                          onChanged: (String? newValue) {
                            vendorName  = newValue!;
                            dropdownVendorInitialValue = newValue;
                            setState((){});
                          },),
                      ),
                    ],
                  ),
                  SizedBox(width:horizontalPadding/2),
                  SizedBox(
                      width: containerWidth*1,
                      child: TextFormField(
                        controller: _invoiceDateController,
                        decoration: const InputDecoration(labelText: 'Date (if different than today\'s mm/dd/yyyy)'),
                        validator: (v) => v!.isEmpty ? 'Enter invoice\'s date': null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            MaskedInputFormatter('##/##/####'),
                          ],
                        onChanged: (val){setState((){
                          invoiceDate = val;
                          _invoiceDateController.selection = TextSelection.fromPosition(TextPosition(offset: _invoiceDateController.text.length));
                        });},
                  ),),
                ],
              ),
              dropdownVendorInitialValue == '- Add new vendor -' ? Padding(
                padding: EdgeInsets.only(right: padding),
                child: TextFormField(
                    enabled: dropdownVendorInitialValue == '- Add new vendor -' ? true : false,
                    controller: _vendorNameController,
                    decoration: const InputDecoration(labelText: 'Vendor Name'),
                    validator: (v) => v!.isEmpty ? 'Enter vendor\'s name': null,
                    onChanged: (val){setState(() => vendorName = val);}
                ),
              ): const SizedBox.shrink(),
              SizedBox(height: verticalPadding/2,),
              ProductInfoFields(index: productLineList.length-1),
              //SizedBox(height: verticalPadding/2,),
              Text(errorOnForm,
                  style: TextStyle(color: Colors.red, fontSize: fontSizeText)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: InkWell(
                      onTap: (){
                        if((int.parse(productQuantityList[productLineList.length-1])>0)&(double.parse(productQuantityList[productLineList.length-1])>0)) {
                          productLineList.insert(productLineList.length, productLineList[productLineList.length-1]);
                          productBrandList.insert(productBrandList.length, productBrandList[productBrandList.length-1]);
                          productModelList.insert(productModelList.length, productModelList[productModelList.length-1]);
                          productGradeList.insert(productGradeList.length, productGradeList[productGradeList.length-1]);
                          productQuantityList.insert(productQuantityList.length, '');
                          productCostList.insert(productCostList.length, '');
                          setState(() {});
                        }else{
                          setState(() => errorOnForm = 'Please, add a quantity and cost');
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Container(
                            height: verticalPadding*2,
                            //width: 50,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.all(Radius.circular(padding)),),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline , color: Colors.white),
                                Text(' Add Product', style: TextStyle(color:Colors.white, fontSize: fontSizeText)),
                              ],)
                        ),
                      ),//delete_outline_rounded
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(padding), child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width:1,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(padding),),),
                  child:SingleChildScrollView(
                    child: Column(
                      children: [
                              SizedBox(height: verticalPadding/2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: (size.width - 4*horizontalPadding)/1.5,
                                      child: Text('  Vendor', style: styleInvoiceHeaders)
                                  ),
                                  SizedBox(
                                      width: (size.width - 4*horizontalPadding)/3,
                                      child: Text('Date: ', style: styleInvoiceHeaders)
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: (size.width - 4*horizontalPadding)/1.5,
                                      child: Text(' ${vendorName.toString()}', style: styleInvoiceValues)
                                  ),
                                  SizedBox(
                                      width: (size.width - 4*horizontalPadding)/3,
                                      child: Text(invoiceDate, style: styleInvoiceValues)
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  SizedBox(width: horizontalPadding),
                                ],
                              ),
                              SizedBox(height: verticalPadding*1.25),
                          Row(
                            children: [
                              SizedBox(
                                width: (size.width - 4*horizontalPadding)/2*1.5,
                                child: Text('  Product description',
                                    textAlign: TextAlign.start,
                                    style: styleInvoiceHeaders),
                              ),
                              SizedBox(
                                width: (size.width - 4*horizontalPadding)/2*.5,
                                child: Text('Price',
                                    textAlign: TextAlign.start,
                                    style: styleInvoiceHeaders),
                              ),
                              ]),
                              ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: productLineList.length-1,
                                  itemBuilder: (BuildContext context, int index) {
                                    return  Row(
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            productLineList.removeAt(index);
                                            productBrandList.removeAt(index);
                                            productModelList.removeAt(index);
                                            productGradeList.removeAt(index);
                                            productQuantityList.removeAt(index);
                                            productCostList.removeAt(index);
                                            setState((){});
                                          },
                                          child:
                                          const Icon(Icons.close , color: Colors.red), //delete_outline_rounded
                                        ),
                                        SizedBox(
                                          width: (size.width - 4*horizontalPadding)/2*1.4,
                                          child: Text('${NumberFormat('#,###').format(int.parse(productQuantityList[index]))} ${productLineList[index]} ${productBrandList[index]} ${productModelList[index]} ${productGradeList[index]}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(fontSize: fontSizeText, color: Colors.black87),)
                                        ),
                                        SizedBox(
                                          width: (size.width - 4*horizontalPadding)/2*.5,
                                          child: Text(NumberFormat('\$#,###.00').format(double.parse(productCostList[index])),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(fontSize: fontSizeText, color: Colors.black87),)
                                        ),
                                      ],
                                    );
                                  }),
                              SizedBox(height: verticalPadding*1.25),
                              /*Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: horizontalPadding),
                                  Text('Freight:',
                                      style: styleInvoiceHeaders),
                                  SizedBox(
                                    width: horizontalPadding + (size.width - 4*horizontalPadding)/2*.5,
                                    child: Text(NumberFormat('\$#,###.00').format(freightPrice), style: TextStyle(fontSize: fontSizeText)),
                                  ),
                                ],
                              ),*/
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: horizontalPadding + (size.width - 4*horizontalPadding)/2*.9,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(NumberFormat('#,###').format(golfBallsTotal), style: TextStyle(fontSize: fontSizeText)),
                                        Text(' golf balls',
                                            style: styleInvoiceHeaders),
                                      ],
                                    ),
                                  ),
                                  Text('Invoice total: ',
                                      style: styleInvoiceHeaders),
                                  SizedBox(
                                    width: horizontalPadding + (size.width - 4*horizontalPadding)/2*.5,
                                    child: Text(NumberFormat('\$#,###.00').format(invoiceTotal), style: TextStyle(fontSize: fontSizeText)),
                                  ),
                                ],
                              ),
                      ],),
                  ),
                ),
                ),
              ),
              SizedBox(width: horizontalPadding, height: verticalPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: InkWell(
                      onTap: () async {
                        if(productLineList.length>1) {
                          if(vendorName != ''){
                            setState(() => loading = true);

                            ///collecting all info required to update location with data from invoice
                            String invoiceId = intFixed(invoices.length, 3);
                            int invoiceSerialNumber = invoices.length;
                            String invoiceName = '${dateToday()} $invoiceSerialNumber $vendorName';

                            List<dynamic> invoiceContent = [{'Quantity': int.parse(productQuantityList[0]),'Line': productLineList[0], 'Brand': productBrandList[0], 'Model': productModelList[0], 'Grade': productGradeList[0], 'Value': double.parse(productCostList[0])}];
                            for(var i=1;i<productLineList.length-1;i+=1){
                              invoiceContent.insert(invoiceContent.length, {'Quantity': int.parse(productQuantityList[i]),'Line': productLineList[i], 'Brand': productBrandList[i], 'Model': productModelList[i], 'Grade': productGradeList[i], 'Value': double.parse(productCostList[i])});
                            }

                            await InvoiceDatabaseService.withoutInvoiceId().updateInvoiceData(invoiceId, vendorName, invoiceName, invoiceSerialNumber, invoiceContent, invoiceContent); ///invoiceContent is given 1st for invoiceCurrentContent, and 2nd for invoiceOriginalContent
                              if(dropdownVendorInitialValue=='- Add new vendor -'){
                                await VendorDatabaseService.withoutVendorId().updateVendorData(intFixed(vendors.length-1, 3), vendorName); /// using vendors.length-1 given that vendor nb 999 is '- Add new vendor -'
                              }
                            /// Adding log of operation to database
                            await ActivityDatabaseService(activityId: timeStampNow()).updateActivity(
                                user.userId,
                                'invoice_added',
                                vendorName,
                                invoiceContent,
                                invoiceName,
                                invoiceContent);

                            _showConfirmationMessage(vendorName, NumberFormat('#,###').format(golfBallsTotal), NumberFormat('\$#,###.00').format(invoiceTotal));

                          }else{
                            setState(() => errorOnForm = 'Please, add a vendor name');
                          }
                        }else{
                          setState(() => errorOnForm = 'Please, add more products before submitting');
                        }
                        setState((){
                          loading = false;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: Container(
                            height: verticalPadding*2,
                            //width: 50,
                            decoration: BoxDecoration(
                              color: productLineList.length>1 ? Colors.green : Colors.black38,
                              borderRadius: BorderRadius.all(Radius.circular(padding)),),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.done_all , color: Colors.white),
                                Text(' Submit Invoice', style: TextStyle(color:Colors.white, fontSize: fontSizeText)),
                              ],)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductInfoFields extends StatefulWidget {
  final int index;
  const ProductInfoFields({Key? key, required this.index}) : super(key: key);

  @override
  createState() => _ProductInfoFieldsState();
}

class _ProductInfoFieldsState extends State<ProductInfoFields> {
  static List<String> productLineOptions = gbLineListDetailed;
  static List<String> productBrandOptions = gbLineBrandMapDetailed[productLineOptions[0]]!;//['Pick line first'];
  static List<String> productModelOptions = gbBrandModelMapDetailed['${productLineOptions[0]} ${productBrandOptions[0]}']!;//['Pick brand first'];
  static List<String> productGradeOptions = gbLineGradeMapDetailed[productLineOptions[0]]!;
  static String dropdownLineInitialValue = productLineOptions[0];
  static String dropdownBrandInitialValue = productBrandOptions[0];
  static String dropdownModelInitialValue = productModelOptions[0];
  static String dropdownGradeInitialValue = productGradeOptions[0];

  TextEditingController _productQuantityController = TextEditingController();
  TextEditingController _productCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productQuantityController = TextEditingController();
    _productCostController = TextEditingController();

  }

  @override
  void dispose() {
    _productQuantityController.dispose();
    _productCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width / 30;
    //final double verticalPadding = size.height / 40;
    //final double fontSizeTitle = pow(size.height, 1/2).toDouble();
    //final double fontSizeSubtitle = pow(size.height, 1 / 2) / 1.5;
    //final double fontSizeText = pow(size.height, 1 / 2) / 1.75;
    final double padding = pow(size.width, 1 / 4) * 1.5;
    double containerWidth = (size.width - padding*4)/3.4;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _productQuantityController.text = _AddInvoice2State.productQuantityList[widget.index];
      _productCostController.text = _AddInvoice2State.productCostList[widget.index];
    });

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width:containerWidth*.8,
              child:const Text('Line'),
            ),
            SizedBox(
              width:containerWidth*.8,
              child:const Text('Brand'),
            ),
            SizedBox(
              width:containerWidth*1.1,
              child:const Text('Model'),
            ),
            SizedBox(
              width:containerWidth*.7,
              child:const Text('Grade'),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: containerWidth*.8,
            child: DropdownButton(
              isExpanded: true,
              value: dropdownLineInitialValue, //initial value
              icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
              items: productLineOptions.map((String option) { // Array list of items
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (String? newValue) {
                productBrandOptions = gbLineBrandMapDetailed[newValue]!;
                dropdownBrandInitialValue = productBrandOptions[0];
                productModelOptions = gbBrandModelMapDetailed['$newValue ${productBrandOptions[0]}']!;
                dropdownModelInitialValue = productModelOptions[0];
                productGradeOptions = gbLineGradeMapDetailed[newValue]!;
                dropdownGradeInitialValue = productGradeOptions[0];
                _AddInvoice2State.productLineList[widget.index] = newValue!;
                _AddInvoice2State.productBrandList[widget.index] = dropdownBrandInitialValue;
                _AddInvoice2State.productModelList[widget.index] = dropdownModelInitialValue;
                _AddInvoice2State.productGradeList[widget.index] = dropdownGradeInitialValue;
                setState(() => dropdownLineInitialValue = newValue);
              },),
            ),
            SizedBox(
              width: containerWidth*.8,
              child: DropdownButton(
                isExpanded: true,
                value: dropdownBrandInitialValue, //initial value
                icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
                items: productBrandOptions.map((String option) { // Array list of items
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (String? newValue) {
                  productModelOptions = gbBrandModelMapDetailed['$dropdownLineInitialValue $newValue']!;
                  dropdownModelInitialValue = productModelOptions[0];
                  _AddInvoice2State.productBrandList[widget.index] = newValue!;
                  _AddInvoice2State.productModelList[widget.index] = dropdownModelInitialValue;
                  _AddInvoice2State.productGradeList[widget.index] = dropdownGradeInitialValue;
                  setState(() => dropdownBrandInitialValue = newValue);
                },
              ),
            ),
        SizedBox(
          width: containerWidth*1.1,
          child: DropdownButton(
            isExpanded: true,
            value: dropdownModelInitialValue, //initial value
            icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
            items: productModelOptions.map((String option) { // Array list of items
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: (String? newValue) {
              _AddInvoice2State.productModelList[widget.index] = newValue!;
              _AddInvoice2State.productGradeList[widget.index] = dropdownGradeInitialValue;
              setState(() => dropdownModelInitialValue = newValue);
            },
          ),
        ),
            SizedBox(
          width: containerWidth*.7,
          child: DropdownButton(
            isExpanded: true,
            value: dropdownGradeInitialValue, //initial value
            icon: const Icon(Icons.keyboard_arrow_down),// Down Arrow Icon
            items: productGradeOptions.map((String option) { // Array list of items
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: (String? newValue) {
              _AddInvoice2State.productGradeList[widget.index] = newValue!;
              setState(() => dropdownGradeInitialValue = newValue);
            },
          ),
        ),
          ],),
            Row(
              children: [
                Flexible(
                  flex: 4,
                  child: TextFormField(
                      controller: _productQuantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        ThousandsSeparatorInputFormatter(),
                      ],
                      onChanged: (vQ) => _AddInvoice2State.productQuantityList[widget.index] = vQ.replaceAll(RegExp('[^0-9]'), ''),
                      decoration: const InputDecoration(labelText: 'Quantity', ),
                      validator: (vQ) => vQ!.isEmpty ? 'Enter quantity': null,
                    ),
                ),
        SizedBox(width: horizontalPadding),
                Flexible(
                  flex: 4,
          child: TextFormField(
              controller: _productCostController,
              keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              CurrencyTextInputFormatter(symbol:'\$', decimalDigits: 0),
            ],
              onChanged: (v) => _AddInvoice2State.productCostList[widget.index] = (v.replaceAll(RegExp('[^0-9]'), '')),
              decoration: const InputDecoration(labelText: 'Cost (\$)'),
              validator: (v) => v!.isEmpty ? 'Enter cost': null,
            ),
        ),
              ],),
      ],);
  }
}


