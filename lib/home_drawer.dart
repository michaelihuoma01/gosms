import 'package:flutter/material.dart';
import 'package:sms/amount_widget.dart';
import 'package:sms/auth.dart';
import 'package:sms/home.dart';
import 'package:sms/payment_widget.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // User user = UserController.getUser();
    final AuthService _auth = AuthService();

    return Container(
      width: 200,
      child: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 50),
            // buildAction("Home", Icons.home, () {
            //   Navigator.of(context).push(MaterialPageRoute(
            //     settings: RouteSettings(name: Home.route),
            //     builder: (context) => Home(),
            //   ));
            // }),
            buildAction("Payments", Icons.payment, () {
              Navigator.of(context).push(MaterialPageRoute(
                settings: RouteSettings(name: Amount.route),
                builder: (context) => Amount(),
              ));
            }),
            Divider(),
            buildAction("Help", Icons.help_outline, () {
              Navigator.of(context).push(MaterialPageRoute(
                settings: RouteSettings(name: Payment.route),
                builder: (context) => Payment(),
              ));
            }),
            Divider(),
            buildAction("Logout", Icons.remove_circle_outline, () async {
              _auth.signOut();
            }),
          ],
        ),
      ),
    );
  }

  Widget buildAction(String title, IconData iconData, Function onPressed) {
    return ListTile(
      onTap: onPressed,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black87, fontSize: 17, fontWeight: FontWeight.normal),
      ),
      leading: Icon(
        iconData,
        color: Colors.black54,
      ),
    );
  }
}
