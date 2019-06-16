import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool registerLoading = false;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String _email;
  String _username;
  String _password;

  @override
  void initState() {
    super.initState();

    _checkSharedPreferences();
  }

  _checkSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('id') != null) {
      // User Has Logged In
    }
  }

  Widget _buildBackground() {
    return Center(
      child: Image.asset(
        'assets/images/jlf-back.png',
        width: globals.mw(context),
        height: globals.mh(context),
        fit: BoxFit.fill,
      ),
    );
  }

  void _register() async {
    if (registerLoading) return;

    if (_formKey.currentState.validate()) {
      setState(() {
        registerLoading = true;
      });

      _formKey.currentState.save();

      var formData = Map<String, dynamic>();
      formData['email'] = _email;
      formData['username'] = _username;
      formData['password'] = _password;
      formData['role_id'] = 2;

      var result = await register(formData);

      if (result != null) {
        prefs.setInt('id', result.id);
        prefs.setString('username', result.username);

        Navigator.of(context).pop();
        Navigator.pushNamed(context, "/home");
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(children: <Widget>[
        // _buildBackground(),
        !registerLoading
            ? Container()
            : Center(child: CircularProgressIndicator()),
        ListView(children: <Widget>[
          Container(
              height: globals.mh(context) * 0.3,
              child: Center(
                child: Image.asset("assets/images/logo.png", height: 120),
              )),
          Form(
            autovalidate: autoValidate,
            key: _formKey,
            child: Column(children: <Widget>[
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    onSaved: (String value) {
                      _email = value;
                    },
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        FocusScope.of(context).requestFocus(usernameFocusNode);
                      }
                    },
                    validator: (value) {
                      Pattern pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(value))
                        return 'Email tidak valid';
                      else
                        return null;
                    },
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        hintText: "Email",
                        labelText: "Email",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    focusNode: usernameFocusNode,
                    onSaved: (String value) {
                      _username = value;
                    },
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        FocusScope.of(context).requestFocus(passwordFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 5 ||
                          value.length > 12) {
                        return 'Username minimal 5 maksimal 12 huruf';
                      }
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        hintText: "Username",
                        labelText: "Username",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    focusNode: passwordFocusNode,
                    onSaved: (String value) {
                      _password = value;
                    },
                    controller: passwordController,
                    onFieldSubmitted: (String value) {
                      if (value.length > 0) {
                        FocusScope.of(context)
                            .requestFocus(confirmPasswordFocusNode);
                      }
                    },
                    validator: (value) {
                      if (value.isEmpty ||
                          value.length < 5 ||
                          value.length > 12) {
                        return 'Password minimal 8 maksimal 12 huruf';
                      }
                    },
                    obscureText: passwordVisibility,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                          child: Icon(passwordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: "Password",
                        labelText: "Password",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: TextFormField(
                    focusNode: confirmPasswordFocusNode,
                    controller: confirmPasswordController,
                    obscureText: confirmPasswordVisibility,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Password tidak sesuai';
                      }
                    },
                    onFieldSubmitted: (String value) {
                      _register();
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(13),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              confirmPasswordVisibility =
                                  !confirmPasswordVisibility;
                            });
                          },
                          child: Icon(confirmPasswordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: "Ulangi Password",
                        labelText: "Ulangi Password",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )),
              Container(
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: FlatButton(
                      onPressed: () => registerLoading ? null : _register(),
                      child: Text(!registerLoading ? "Daftar" : "Mohon Tunggu",
                          style: Theme.of(context).textTheme.display4),
                      color: registerLoading
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
              Container(
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text("Kembali ke halaman login",
                          style: TextStyle(color: Colors.grey)))),
              // FlatButton(
              //     onPressed: () => setState(() {
              //           registerLoading = false;
              //         }),
              //     child: Text("RESET"))
            ]),
          ),
        ])
      ])),
    );
  }
}
