import 'package:intl/intl.dart';

class AppUser {
  final String userId;
  AppUser({required this.userId});
}

class UserData{
  final String userId;
  final String userName;
  final String role;
  List<dynamic> cartContent;
  UserData({required this.userId, required this.userName, required this.role, required this.cartContent});

  @override
  String toString() => '$userId, $role, $userName, $cartContent';

  void validateContent(){
    int contentNumberOf = cartContent.length;
    for(var i=0;i<contentNumberOf;i+=1){
      if(cartContent[i]['Quantity'] == 0){
        //print('Content $i got empty and was deleted, ${cartContent[i]}');
        cartContent.removeAt(i);
        i-=1;
        contentNumberOf = cartContent.length;
      }
    }
  }

  void addContent (Map<String, dynamic> contentBeingAdded){
    String line = contentBeingAdded['Line'];
    String brand = contentBeingAdded['Brand'];
    String model = contentBeingAdded['Model'];
    String grade = contentBeingAdded['Grade'];
    int quantity = contentBeingAdded['Quantity'];
    double value = contentBeingAdded['Value'];

    bool matchNotFound = true;
    int contentNumberOf = cartContent.length;

    for(var i=0;i<contentNumberOf;i+=1){
      if(cartContent[i]['Line'] == line){
        if(cartContent[i]['Brand'] == brand){
          if(cartContent[i]['Model'] == model) {
            if (cartContent[i]['Grade'] == grade) {
              matchNotFound = false;
              //adding to this location
              cartContent[i]['Quantity'] += quantity;
              cartContent[i]['Value'] += value;
              //print('Match found, new content has ${cartContent[i]['Quantity']} valued at ${cartContent[i]['Value']}');
            } else {
              //print('$i: different Grade ${cartContent[i]['Grade']} vs $grade');
            }
          } else {
            //print('$i: different Model ${cartContent[i]['Model']} vs $model');
          }
        } else {
          //print('$i: different Brand ${cartContent[i]['Brand']} vs $brand');
        }
      } else {
        //print('$i: different Line ${cartContent[i]['Line']} vs $line');
      }
    }
    if(matchNotFound){
      cartContent.insert(contentNumberOf, {'Line': line,'Brand': brand,'Model': model, 'Grade': grade, 'Quantity': quantity, 'Value': value});
      //print('No match found.');
      //print('New content added in position ${contentNumberOf + 1}');
    }
  }

  void removeContent (index, quantityBeingRemoved){
    var valueBeingRemoved = cartContent[index]['Value'] / cartContent[index]['Quantity'] * quantityBeingRemoved;
    cartContent[index]['Quantity'] -= quantityBeingRemoved;
    cartContent[index]['Value'] -= valueBeingRemoved;
    //print('removed content $index from $userName: $quantityBeingRemoved ${content['Line']} ${content['Brand']} ${content['Model']} ${content['Grade']} @ $valueBeingRemoved');
    validateContent();
  }
}

class UserInformation {
  final String userName;
  final String role;
  List<dynamic> cartContent;
  UserInformation({ required this.userName, required this.role, required this.cartContent});
  @override
  String toString(){
    var returnText = '';
    cartContent.isEmpty ? returnText = 'Empty cart' : returnText = 'Cart content: ';
    for(var i=0;i<cartContent.length;i+=1){
      returnText = '$returnText \n - ${NumberFormat('#,###').format(cartContent[i]['Quantity'])} ${cartContent[i]['Line']} ${cartContent[i]['Brand']} ${cartContent[i]['Model']} ${cartContent[i]['Grade']}';//@ ${NumberFormat('\$#,###.00').format(cartContent[i]['Value'])}
    }
    return returnText;
  }
}