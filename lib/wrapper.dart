import 'package:flutter/material.dart';
import 'package:sms/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:sms/home.dart';
import 'package:sms/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser>(context);
    
    // return either Home or Authenticate widget
    if(user == null) {
      return Authenticate();
    } else {
      return Home();
    }
     
  }
}