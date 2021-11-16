import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms/user.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  final CollectionReference userRef = FirebaseFirestore.instance.collection('users');

  Future setUserData(String name, String email, String mobile) async {
    return await userRef.doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  Future updateUserData(String name, String email, String mobile) async {
    return await userRef.doc(uid).set({
      'name': name,
      'email': email,
    });
  }

  // Stream<DocumentSnapshot> get userLocation {
  //   return driverRef.document(uid).get().then((onValue) {
      
  //   });
  // }

  // get users stream
  Stream<QuerySnapshot> get users {
    return userRef.snapshots();
  }
}