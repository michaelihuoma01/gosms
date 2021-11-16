import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sms/home_drawer.dart';
import 'package:sms/internet.dart';
import 'package:sms/loading.dart';
import 'package:sms_maintained/sms.dart';

class Home extends StatefulWidget {
  static const route = "/homeScreen";

  @override
  _HomeState createState() => _HomeState();
}

final _formKey = GlobalKey<FormState>();

class _HomeState extends State<Home> {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  TextEditingController _controllerPeople,
      _controllerMessage,
      _controllerCount,
      _controllerMe;
  String _message, body;
  String _canSendSMSMessage = "Check is not run.";

  int count;
  static int _counter = 0;
  static int _counterD = 0;
  static int _coins;
  static int _coinSum;
  String people, title;

  String recipent = '';
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String sender = '';
  String text = '';
  String amount = '';
  Timer _timer, _time;
  String bText = "Send";
  bool conectivityStatus = false;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getCoins();
    title = "You have " + _coins.toString() + " coins";
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    Duration duration = const Duration(hours: 150);
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.

    result = await _connectivity.checkConnectivity();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      conectivityStatus = false;
      _scaffoldKey.currentState.removeCurrentSnackBar();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      conectivityStatus = false;
      _scaffoldKey.currentState.removeCurrentSnackBar();
    } else {
      conectivityStatus = true;
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text("Please connect to a network"),
        duration: duration,
        action: new SnackBarAction(
            label: 'OK',
            onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()),
      ));
    }
  }

  Future<void> initPlatformState() async {
    _controllerPeople = TextEditingController();
    _controllerMe = TextEditingController();
    _controllerMessage = TextEditingController();
    _controllerCount = TextEditingController();
  }

  // updateCoins() async {

  //   setState(() {});
  // }

  void _sendSMS() async {
    try {
      SmsSender sender = new SmsSender();

      final FirebaseAuth authe = FirebaseAuth.instance;
      final User userid = authe.currentUser;
      String uid = userid.uid;

      SmsMessage message =
          new SmsMessage(_controllerPeople.text, _controllerMessage.text);

      setState(() {
        _counter++;
      });

      if (_counter == count) {
        _coinSum = (_coins - _counter);
        title = "You have " + _coins.toString() + " coins";
        _database.collection('users').doc(uid).update({
          'coins': _coinSum,
        });
      }

      message.onStateChanged.listen((state) async {
        if (state == SmsMessageState.Sent) {
          setState(() {
            _message = ' Delivering...';
          });

          Future.delayed(const Duration(seconds: 5), () {});

          print('Sent');
        } else if (state == SmsMessageState.Delivered) {
          sender.onSmsDelivered.listen((SmsMessage message) async {
            setState(() => {
                  _counterD++,
                  _message = _counterD.toString() + ' sms delivered',
                  // _counterD - _coins,
                });

            print('Delivered!');
          });
        }
      });
      sender.sendSms(message);
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    endSms();
    getCoins();
    initConnectivity();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: conectivityStatus
          ? Internet()
          : Scaffold(
              // home: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(title,
                    style: TextStyle(color: Colors.black, fontSize: 17)),
                centerTitle: true,
                backgroundColor: Colors.white,
                iconTheme: new IconThemeData(color: Color(0xff008081)),
              ),
              drawer: HomeDrawer(),
              backgroundColor: Colors.white,
              body: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    // HomeAppBar(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 0, left: 50, right: 50),
                      child: ListTile(
                        title: TextFormField(
                          controller: _controllerMe,
                          cursorColor: Color(0xff008081),
                          decoration: InputDecoration(
                            labelText: "Enter your phone number",
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => val.isEmpty
                              ? "Please enter sender's number"
                              : null,
                          onChanged: (val) {
                            setState(() => sender = val);
                          },
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 0, left: 50, right: 50),
                      child: ListTile(
                        title: TextFormField(
                          controller: _controllerPeople,
                          cursorColor: Color(0xff008081),
                          decoration: InputDecoration(
                            labelText: "Enter recipient's number",
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => val.isEmpty
                              ? "Please enter recipient's number"
                              : null,
                          onChanged: (val) {
                            setState(() => recipent = val);
                          },
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: ListTile(
                        title: TextFormField(
                          cursorColor: Color(0xff008081),
                          decoration: InputDecoration(
                              labelText: "Enter your message",
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                          controller: _controllerMessage,
                          validator: (val) =>
                              val.isEmpty ? "Please enter a message" : null,
                          onChanged: (val) {
                            setState(() => text = val);
                          },
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: ListTile(
                        title: TextFormField(
                          cursorColor: Color(0xff008081),
                          decoration: InputDecoration(
                              labelText: "Number of sms",
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white))),
                          controller: _controllerCount,
                          keyboardType: TextInputType.number,
                          validator: (val) => val.isEmpty
                              ? "Please enter the amount of sms you want to send"
                              : null,
                          onChanged: (val) {
                            setState(() => amount = val);
                          },
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 50.0, right: 50.0, bottom: 20),
                      child: RaisedButton(
                        color: Color(0xff008081),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(bText,
                            style: Theme.of(context).accentTextTheme.button),
                        onPressed: () => {
                          _send(),
                        },
                      ),
                    ),

                    Center(
                      child: Visibility(
                        visible: _message != null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0.0,
                                    left: 70.0,
                                    right: 50.0,
                                    bottom: 20),
                                child: Text(
                                  _message ?? "No Data",
                                  maxLines: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Center(
                      child: Visibility(
                        visible: _message != null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0.0,
                                    left: 70.0,
                                    right: 50.0,
                                    bottom: 20),
                                child: Text(
                                    "Sent " +
                                            _counter.toString() +
                                            " of " +
                                            _controllerCount.text ??
                                        "No Data",
                                    maxLines: null),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void test() {
    setState(() {
      _counter++;
      _coins = (_coins - _counterD);

      title = "You have " + _coins.toString() + " coins";
    });
    print(_counter);
    print(_coins);
    print('Testing...');
  }

  void endSms() async {
    if (_counter == count || _counter == 100) {
      setState(() {
        bText = "Send";
      });
      _timer.cancel();
    }
  }

  void _send() async {
    if (_formKey.currentState.validate()) {
      count = int.parse(_controllerCount.text);
      if (_coins < count) {
        setState(() {
          _message = "You do not have enough coins";
        });

        print("You dont have enough coins");
        _timer.cancel();
      } else {
        setState(() {
          bText = "Sending...";
        });

        _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
          _sendSMS();
          // test();
          print(_coins);
        });
      }
    }
    addDatato();
  }

  addDatato() async {
    final FirebaseAuth authe = FirebaseAuth.instance;
    final User userid = authe.currentUser;
    String uid = userid.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('users');
    await reference.doc(uid).collection('sms').doc().set({
      'senderNo': _controllerMe.text,
      'recipientNo': _controllerPeople.text,
      'text': _controllerMessage.text,
      'counter': _controllerCount.text,
    });
  }

  getCoins() async {
    final FirebaseAuth authe = FirebaseAuth.instance;
    final User userid = authe.currentUser;
    String uid = userid.uid;
    _database.collection('users').doc(uid).get().then((docs) async {
      _coins = docs['coins'];
      setState(() {
        title = "You have " + _coins.toString() + " coins";
      });
      // print(_coins);
    });
  }
}
