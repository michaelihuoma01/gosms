import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';
import 'package:sms/amount_widget.dart';
import 'package:sms/auth.dart';
import 'package:sms/home.dart';
import 'package:sms/payment_widget.dart';
import 'package:sms/user.dart';
import 'package:sms/wrapper.dart';

// The existing imports
// !! Keep your existing impots here !!

/// main is entry point of Flutter application

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  // plugin .initialize(publicKey: paystackPublicKey);
  await Firebase.initializeApp();
  return runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  PaystackPlugin plugin = PaystackPlugin();
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          Amount.route: (context) => Amount(),
          Payment.route: (context) => Payment(),
          Home.route: (context) => Home()
        },
      ),
    );
  }
}
