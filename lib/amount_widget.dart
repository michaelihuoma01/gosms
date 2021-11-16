import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:sms/home_drawer.dart';
import 'package:http/http.dart' as http;

class Amount extends StatefulWidget {
  static const route = "/amountScreen";
  @override
  _AmountState createState() => _AmountState();
}

class _AmountState extends State<Amount> {
  TextEditingController _controllerCoins;
  String coins;

  //Paystack initializations
  var publicKey = 'pk_live_eadc87c533eac1f626ac203c8b7541dc9c8fa1a7';
  // String backendUrl = 'https://gosmsapp.herokuapp.com';
  CheckoutMethod _method;
  var banks = ['Select', 'Card'];
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _inProgress = false;
  bool get _isLocal => _radioValue == 0;
  int _radioValue = 0;
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  String _email, _coins, _reference;
  int amount, coinssum;
  Timer _timer;

  Future<void> initPlatformState() async {
    _controllerCoins = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getEmail();
  }

  Widget _getPlatformButton(String string, Function() function) {
    // is still in progress
    Widget widget;
    if (Platform.isIOS) {
      widget = new CupertinoButton(
        onPressed: function,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        color: CupertinoColors.activeBlue,
        child: new Text(
          string,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      widget = new RaisedButton(
        onPressed: function,
        color: Colors.blueAccent,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: new Text(
          string.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Buy coins",
                  style: TextStyle(color: Colors.black, fontSize: 17)),
              centerTitle: true,
              backgroundColor: Colors.white,
              iconTheme: new IconThemeData(color: Color(0xff008081)),
            ),
            drawer: HomeDrawer(),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: ListTile(
                      title: Center(
                        child: Text('1 coin = 1 naira'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: ListTile(
                      title: TextFormField(
                        cursorColor: Color(0xff008081),
                        decoration: InputDecoration(
                            labelText: "Amount in naira",
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                        controller: _controllerCoins,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val.isEmpty ? "Field cannot be blank" : null,
                        // onChanged: (val) { setState(() => amount = val);},
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: new DropdownButtonHideUnderline(
                      child: new InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'Checkout method',
                        ),
                        isEmpty: _method == null,
                        child: new DropdownButton<CheckoutMethod>(
                          value: _method,
                          isDense: true,
                          onChanged: (CheckoutMethod value) {
                            setState(() {
                              _method = value;
                            });
                          },
                          items: banks.map((String value) {
                            return new DropdownMenuItem<CheckoutMethod>(
                              value: _parseStringToMethod(value),
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: RaisedButton(
                      color: Color(0xff008081),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Proceed to payment",
                          style: Theme.of(context).accentTextTheme.button),
                      onPressed: () => {
                        amount = int.parse(_controllerCoins.text),
                        // _startAfreshCharge(),
                        // _handleCheckout(context),
                        print(coinssum),
                        print(amount)
                      },
                    ),
                  ),
                ],
              ),
            )));
  }

  // handleOnSuccess() async {
  // bool response = await _verifyOnServer(transaction.reference);
  // if (response) {
  //   try {
  //   final FirebaseAuth authe = FirebaseAuth.instance;
  //   final FirebaseUser userid = await authe.currentUser();
  //   String uid = userid.uid;
  //   _database.collection('users').document(uid).get().then((docs) async {
  //     _coins = docs.data['coins'].toString();
  //   });

  //   A.CollectionReference reference =
  //       A.Firestore.instance.collection('users');

  //   _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
  //   coinssum = int.parse(_coins) + int.parse(_controllerCoins.text);
  //    reference.document(uid).updateData({
  //     'coins': coinssum,
  //   });
  // });

  //   } on PlatformException catch (error) {
  //     _showMessage("Error");
  //   }
  // }
  // }

  getEmail() async {
    final FirebaseAuth authe = FirebaseAuth.instance;
    final User userid = authe.currentUser;
    String uid = userid.uid;

    _database.collection('users').doc(uid).get().then((docs) async {
      _email = docs['email'];
      print(_email);
    });
  }

  CheckoutMethod _parseStringToMethod(String string) {
    CheckoutMethod method = CheckoutMethod.selectable;
    switch (string) {
      // case 'Bank':
      //   method = CheckoutMethod.bank;
      //   break;
      case 'Card':
        method = CheckoutMethod.card;
        break;
    }
    return method;
  }

  _showMessage(String message,
      [Duration duration = const Duration(seconds: 10)]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE',
          onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()),
    ));
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Future<String> _fetchAccessCodeFrmServer(String reference) async {
  //   String url = '$backendUrl/new-access-code';
  //   String accessCode;
  //   try {
  //     print("Access code url = $url");
  //     http.Response response = await http.get(url);
  //     accessCode = response.body;
  //     print('Response for access code = $accessCode');
  //   } catch (e) {
  //     setState(() => _inProgress = false);
  //     _updateStatus(
  //         reference,
  //         'There was a problem getting a new access code form'
  //         ' the backend: $e');
  //   }

  //   return accessCode;
  // }

  Future<String> _fetchAccessCodeFrmServer(String reference) async {
    int amounts = amount * 100;
    var map = Map<String, dynamic>();
    map['email'] = _email;
    map['amount'] = amounts.toString();
    String url = '';
    String accessCode;
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: map, headers: {"Accept": "application/json"});
      List result = json.decode(response.body);

      Map<String, dynamic> maps;

      for (int i = 0; i < result.length; i++) {
        maps = result[i];
      }
      accessCode = maps['code'];
      print(accessCode);
    } catch (e) {
      setState(() => _inProgress = false);
      _updateStatus(reference, 'There was a problem getting access code');
    }

    return accessCode;
  }

  Future<bool> _verifyOnServer(String reference) async {
    bool rep;
    var map = Map<String, dynamic>();
    map['reference'] = reference;
    _updateStatus(reference, 'Verifying...');
    String url = '';
    List result;
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: map, headers: {"Accept": "application/json"});
      result = json.decode(response.body);
      print(result);
      Map<String, dynamic> maps;

      for (int i = 0; i < result.length; i++) {
        maps = result[i];
      }
      if (maps['status'] == "success") {
        rep = true;
      }
    } catch (e) {
      _updateStatus(reference,
          'There was a problem verifying your transaction on the server:');
      rep = false;
    }
    setState(() => _inProgress = false);
    return rep;
  }

  _updateStatus(String reference, String message) {
    _showMessage('Reference: $reference \n\ Response: $message',
        const Duration(seconds: 7));
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

//   _startAfreshCharge() async {
//     _formKey.currentState.save();

//     Charge charge = Charge();
//     charge.card = _getCardFromUI();

//     setState(() => _inProgress = true);

//     if (_isLocal) {
//       // Set transaction params directly in app (note that these params
//       // are only used if an access_code is not set. In debug mode,
//       // setting them after setting an access code would throw an exception

//       charge
//         ..amount = amount * 100 // In base currency
//         ..email = _email
//         ..reference = _getReference()
//         ..putCustomField('Charged From', 'GoSMS');
//       _chargeCard(charge);
//     } else {
//       // Perform transaction/initialize on Paystack server to get an access code
//       // documentation: https://developers.paystack.co/reference#initialize-a-transaction
//       charge.accessCode = await _fetchAccessCodeFrmServer(_getReference());
//       _chargeCard(charge);
//     }
//   }

//   _chargeCard(Charge charge) {
//     // This is called only before requesting OTP
//     // Save reference so you may send to server if error occurs with OTP
//     handleBeforeValidate(Transaction transaction) {
// //      _updateStatus(transaction.reference, 'validating...');
//       setState(() {
//         _reference = transaction.reference;
//       });
//     }

//     handleOnError(Object e, Transaction transaction) {
//       // If an access code has expired, simply ask your server for a new one
//       // and restart the charge instead of displaying error
//       if (e is Expir) {
//         _startAfreshCharge();
//         _chargeCard(charge);
//         return;
//       } else if (e is AuthenticationException) {
//         setState(() => _inProgress = false);
//         _showMessage("Failed to authenticate your card please");

//         return;
//       } else if (e is InvalidAmountException) {
//         setState(() => _inProgress = false);

//         _showMessage("Invalid amount");

//         return;
//       } else if (e is InvalidEmailException) {
//         setState(() => _inProgress = false);
//         _showMessage("Invalid email entered please try again");

//         return;
//       } else if (e is CardException) {
//         setState(() => _inProgress = false);
//         _showMessage("Card not valid, try again");

//         return;
//       } else if (e is ChargeException) {
//         setState(() => _inProgress = false);
//         _showMessage("Failed to charge card, please try again");
//         print(e.message);

//         return;
//       } else if (e is PaystackException) {
//         setState(() => _inProgress = false);
//         _showMessage("Paystack is currently not available, please try again");
//         return;
//       } else if (e is PaystackSdkNotInitializedException) {
//         setState(() => _inProgress = false);
//         _showMessage("paystack not initialized, try again");
//         return;
//       } else if (e is ProcessException) {
//         setState(() => _inProgress = false);
//         _showMessage(
//             "A transaction is currently processing, please wait till it concludes before attempting a new charge");
//         return;
//       }

//       if (transaction.reference != null) {
//         _verifyOnServer(transaction.reference);
// //        _showErrorDialog("verifying transaction on server", "failed");
//         return;
//       } else {
//         setState(() => _inProgress = false);
// //        _updateStatus(transaction.reference, e.toString());
//       }
//     }

//     // This is called only after transaction is successful
//     handleOnSuccess(Transaction transaction) async {
//       bool response = await _verifyOnServer(transaction.reference);
//       if (response) {
//         try {
//           final FirebaseAuth authe = FirebaseAuth.instance;
//           final FirebaseUser userid = await authe.currentUser();
//           String uid = userid.uid;
//           _database.collection('users').document(uid).get().then((docs) async {
//             _coins = docs.data['coins'].toString();
//           });

//           A.CollectionReference reference =
//               A.Firestore.instance.collection('users');

//           _showSuccessDialog('You have successfully purchased $amount coins', 'Payment Successful');
//           _showMessage("Payment Successful \n You have successfully purchased $amount coins");

//           _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
//             coinssum = int.parse(_coins) + int.parse(_controllerCoins.text);
//             reference.document(uid).updateData({
//               'coins': coinssum,
//             });
//           });
//         } on PlatformException catch (error) {
//           _showMessage(error.message + "Error");
//         }
//       }
//     }

//     PaystackPlugin.chargeCard(
//       context,
//       charge: charge,
//       beforeValidate: (transaction) => handleBeforeValidate(transaction),
//       onSuccess: (transaction) => handleOnSuccess(transaction),
//       onError: (error, transaction) => handleOnError(error, transaction),
//     );
//   }

//   _handleCheckout(BuildContext context) async {
//     if (_method == null) {
//       _showMessage('Select checkout method first');
//       return;
//     }

//     if (_method != CheckoutMethod.card && _isLocal) {
//       _showMessage('Select initialization method at the top');
//       return;
//     }
//     setState(() => _inProgress = true);
//     _formKey.currentState.save();
//     Charge charge = Charge()
//       ..amount = amount * 100 // In base currency
//       ..email = _email
//       ..card = _getCardFromUI();

//     if (!_isLocal) {
//       var accessCode = await _fetchAccessCodeFrmServer(_getReference());
//       charge.accessCode = accessCode;
//     } else {
//       charge.reference = _getReference();
//     }

//     try {
//       CheckoutResponse response = await PaystackPlugin.checkout(
//         context,
//         method: _method,
//         charge: charge,
//         fullscreen: false,
//         logo: MyLogo(),
//       );
//       print('Response = $response');
//       setState(() => _inProgress = false);
//       _updateStatus(response.reference, '$response');

//       bool resp = await _verifyOnServer(response.reference);
//     } catch (e) {
//       setState(() => _inProgress = false);
//       _showMessage("Error occured");
//       rethrow;
//     }

//     handleBeforeValidate(Transaction transaction) {
// //      _updateStatus(transaction.reference, 'validating...');
//       setState(() {
//         // _reference = transaction.reference;
//       });
//     }

//     handleOnError(Object e, Transaction transaction) {
//       // If an access code has expired, simply ask your server for a new one
//       // and restart the charge instead of displaying error
//       if (e is ExpiredAccessCodeException) {
//         _handleCheckout(context);
//         return;
//       } else if (e is AuthenticationException) {
//         setState(() => _inProgress = false);
//         _showMessage("Failed to authenticate your card please");

//         return;
//       } else if (e is InvalidAmountException) {
//         setState(() => _inProgress = false);

//         _showMessage("Invalid amount");

//         return;
//       } else if (e is InvalidEmailException) {
//         setState(() => _inProgress = false);
//         _showMessage("Invalid email entered please try again");

//         return;
//       } else if (e is CardException) {
//         setState(() => _inProgress = false);
//         _showMessage("Card not valid, try again");

//         return;
//       } else if (e is ChargeException) {
//         setState(() => _inProgress = false);
//         _showMessage("Failed to charge card, please try again");
//         print(e.message);

//         return;
//       } else if (e is PaystackException) {
//         setState(() => _inProgress = false);
//         _showMessage("Paystack is currently not available, please try again");
//         return;
//       } else if (e is PaystackSdkNotInitializedException) {
//         setState(() => _inProgress = false);
//         _showMessage("paystack not initialized, try again");
//         return;
//       } else if (e is ProcessException) {
//         setState(() => _inProgress = false);
//         _showMessage(
//           "A transaction is currently processing, please wait till it concludes before attempting a new charge",
//         );
//         return;
//       }

//       if (transaction.reference != null) {
//         _verifyOnServer(transaction.reference);
//       //  _showErrorDialog("verifying transaction on server", "failed");
//         return;
//       } else {
//         setState(() => _inProgress = false);
// //        _updateStatus(transaction.reference, e.toString());
//       }
//     }

//     // This is called only after transaction is successful
//     handleOnSuccess(Transaction transaction) async {
//       bool response = await _verifyOnServer(transaction.reference);
//       if (response) {
//         try {
//           final FirebaseAuth authe = FirebaseAuth.instance;
//           final FirebaseUser userid = await authe.currentUser();
//           String uid = userid.uid;
//           _database.collection('users').document(uid).get().then((docs) async {
//             _coins = docs.data['coins'].toString();
//           });

//           A.CollectionReference reference =
//               A.Firestore.instance.collection('users');

//           _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
//             coinssum = int.parse(_coins) + int.parse(_controllerCoins.text);
//             reference.document(uid).updateData({
//               'coins': coinssum,
//             });
//           });
//         } on PlatformException catch (error) {
//           _showMessage("Error");
//         }
//       }
//     }

//     PaystackPlugin.chargeCard(
//       context,
//       charge: charge,
//       beforeValidate: (transaction) => handleBeforeValidate(transaction),
//       onSuccess: (transaction) => handleOnSuccess(transaction),
//       onError: (error, transaction) => handleOnError(error, transaction),
//     );
//   }

//   _showSuccessDialog(String message, String status) {
//     showDialog(
//         context: context,
//         builder: (_) {
//           return AlertDialog(
//             title: Text(status),
//             content: Text(message),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('Close'),
//                 onPressed: () {
//                   Navigator.of(context, rootNavigator: true).pop();
//                 },
//               )
//             ],
//           );
//         });
//   }
// }
}

class MyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: new DecorationImage(
            image: AssetImage('assets/icon.png'), fit: BoxFit.contain),
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      // alignment: Alignment.center,
      // padding: EdgeInsets.all(10),
      // child: Text(
      //   "CO",
      //   style: TextStyle(
      //     color: Colors.white,
      //     fontSize: 13,
      //     fontWeight: FontWeight.bold,
      //   ),
      // ),
    );
  }
}
