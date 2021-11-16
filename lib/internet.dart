import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Internet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SpinKitPulse(
              color: Color(0xff008081),
              size: 50.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text('No network available', style: TextStyle(fontSize: 20)),
          )
        ],
      ),
    );
  }
}
