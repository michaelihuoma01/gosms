import 'package:flutter/material.dart';
import 'package:sms/home_app_bar.dart';
import 'package:sms/home_drawer.dart';

class Payment extends StatefulWidget {
  static const route = "/paymentScreen";

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("How to use",
            style: TextStyle(color: Colors.black, fontSize: 17)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: Color(0xff008081)),
      ),
      drawer: HomeDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: ListView(
            children: <Widget>[
              Text("1. Input your mobile number", textAlign: TextAlign.left),
              Divider(),
              Text("2. Input recipient's number"),
              Divider(),
              Text("3. Input text message"),
              Divider(),
              Text("4. Input the number of sms you want to send"),
              Divider(),
              Text("5. Tap on send"),
              Divider(),
              Text("6. Text messages are sent using coins"),
              Text("     NOTE: NORMAL SMS CHARGES STILL APPLY",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Divider(),
              Text("7. 1 sms = 1 coin & 1 coin = 1 naira"),
              Divider(),
              Text("8. Purchase of coins can be made on the payments   \n    page"),
              Text("    NOTE: IN-APP PAYMENTS ONLY",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Divider(),
              Text("9. Payments can be made using card only"),
              Divider(),
                  Text("10. Please ensure you have sufficient airtime before   \n      sending sms"),
                  Divider(),
              Text("    NOTE: SMS IS SENT USING ONLY SIM 1",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
