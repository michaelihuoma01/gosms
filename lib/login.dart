import 'package:flutter/material.dart';
import 'package:sms/auth.dart';
import 'package:sms/constants.dart';
import 'package:sms/loading.dart';

class Login extends StatefulWidget {
  final Function toggleView;
  Login({this.toggleView});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // textfield state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
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
                          'Hi!',
                          style: TextStyle(
                              color: Color(0xff008081),
                              fontSize: 50.0,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
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
                          keyboardType: TextInputType.emailAddress,
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
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => loading = true);
                                  dynamic result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      error = 'Could not sign in';
                                      loading = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Center(
                          child: FlatButton(
                            color: Colors.white,
                            child: Text(
                              'First time here? Register',
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
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          );
  }
}
