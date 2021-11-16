import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sms/user.dart';
import 'package:sms/auth.dart';
import 'package:sms/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // textfield state
  String email = '';
  String name = '';
  String mobile = '';
  String password = '';
  String error = '';

  TextEditingController _controllerName, _controllerEmail;

  AppUser _userFromFirebaseUser(User user) {
    return user != null ? AppUser(uid: user.uid) : null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _controllerName = TextEditingController();
    _controllerEmail = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              padding:
                  EdgeInsets.only(top: 80, left: 30, right: 30, bottom: 30),
              children: <Widget>[
               Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Hello Newbie!',
                      style: TextStyle(
                          color: Color(0xff008081),
                          fontSize: 40.0,
                          fontWeight: FontWeight.w700),
                    ),
                    TextFormField(
                      controller: _controllerName,
                      decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      cursorColor: Color(0xff008081),
                      validator: (val) =>
                          val.isEmpty ? 'Enter your name' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    Divider(),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      cursorColor: Color(0xff008081),
                      validator: (val) =>
                          val.isEmpty ? 'Enter a valid email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    Divider(),
                    SizedBox(height: 20.0),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                      cursorColor: Color(0xff008081),
                      validator: (val) => val.length < 6
                          ? 'Password should be atleast 6 chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: ButtonTheme(
                        minWidth: 300,
                        child: RaisedButton(
                          color: Color(0xff008081),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)),
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      email, password);
                              addDatato();
                              if (result == null) {
                                setState(() {
                                  error = 'Please enter a valid email';
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Center(
                      child: FlatButton(
                        color: Colors.white,
                        child: Text(
                          'Been here before? Login',
                          style: TextStyle(
                              color: Color(0xff008081),
                              fontSize: 15.0,
                              fontWeight: FontWeight.normal),
                        ),
                        onPressed: () {
                          widget.toggleView();
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Center(
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 15.0),
                      ),
                    ),
                  ],
                ),
              ),
              ]
            ),
          );
  }

  addDatato() async {
    final FirebaseAuth authe = FirebaseAuth.instance;
    final User userid =  authe.currentUser;
    String uid = userid.uid;
    CollectionReference reference = FirebaseFirestore.instance.collection('users');
    await reference.doc(uid).set({
      'name': _controllerName.text,
      'email': email,
      'coins': 0,
    });
  }
}
