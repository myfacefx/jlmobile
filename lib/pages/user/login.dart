import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jlf_mobile/services/user_services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  SharedPreferences prefs;
  FacebookLogin facebookLogin = FacebookLogin();

  final _formKey = GlobalKey<FormState>();

  FocusNode passwordFocusNode = FocusNode();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = true;

  bool loginLoading = false;
  bool autoValidate = false;

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
      Navigator.of(context).pushNamed("/home");
    }
  }

  _logIn() async {
    if (loginLoading) return;

    if (_formKey.currentState.validate()) {
      setState(() {
        loginLoading = true;
      });

      _formKey.currentState.save();

      var formData = Map<String, dynamic>();
      formData['username'] = _username;
      formData['password'] = _password;

      var result = await login(formData);
      if (result != null && result.id != null) {
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

  Widget _floatingButton(String icon) {
    Color backgr =
        icon == "Facebook" ? Color.fromRGBO(45, 80, 155, 1) : Colors.white;

    Color clrText = icon != "Facebook" ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: FloatingActionButton.extended(
        onPressed: () {
          facebookLogin.logInWithReadPermissions(['email']).then((result) {
            print("TOKEN: " + result.accessToken.token);

            switch (result.status) {
              case FacebookLoginStatus.loggedIn:
                // print(result.)
                print(result.accessToken.token);
                break;
              case FacebookLoginStatus.cancelledByUser:
                throw new StateError("Cancelled by user");
                break;
              case FacebookLoginStatus.error:
                throw new StateError(FacebookLoginStatus.error.toString());
                break;
            }
          }).catchError((e) {
            print("ERROR");
            print(e);
          });
          // Navigator.pushNamed(context, "/home");
        },
        backgroundColor: backgr,
        label: Container(
            padding: EdgeInsets.fromLTRB(0, 0, globals.mw(context) * 0.1, 0),
            child: Text(
              icon,
              style: TextStyle(color: clrText),
            )),
        icon: Container(
          padding: EdgeInsets.fromLTRB(10, 0, globals.mw(context) * 0.05, 0),
          child: Container(
            height: 18,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Image.asset(
              "assets/images/$icon.png",
              height: 25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      child: Center(
        child: Image.asset(
          'assets/images/jlf-back.png',
          width: globals.mw(context),
          height: globals.mh(context),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            _buildBackground(),
            !loginLoading
                ? Container()
                : Center(child: CircularProgressIndicator()),
            ListView(
              children: <Widget>[
                Container(
                    height: globals.mh(context) * 0.4,
                    child: Center(
                      child: Image.asset("assets/images/logo.png", height: 140),
                    )),
                Form(
                  autovalidate: autoValidate,
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: TextFormField(
                            validator: (String value) {
                              if (value.isEmpty) return 'Username masih kosong';
                            },
                            onSaved: (String value) => _username = value,
                            onFieldSubmitted: (String value) {
                              if (value.length > 0)
                                FocusScope.of(context)
                                    .requestFocus(passwordFocusNode);
                            },
                            style: TextStyle(color: Colors.black),
                            controller: usernameController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(13),
                                hintText: "Username",
                                labelText: "Username",
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          )),
                      Padding(padding: EdgeInsets.only(top: 5)),
                      Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: TextFormField(
                            validator: (String value) {
                              if (value.isEmpty) return 'Password masih kosong';
                            },
                            onFieldSubmitted: (String value) => _logIn(),
                            onSaved: (String value) => _password = value,
                            focusNode: passwordFocusNode,
                            obscureText: passwordVisibility,
                            controller: passwordController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
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
                                contentPadding: EdgeInsets.all(13),
                                hintText: "Password",
                                labelText: "Password",
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          )),
                      Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: FlatButton(
                              onPressed: () => loginLoading ? null : _logIn(),
                              child: Text(loginLoading ? "Loading" : "LOG IN",
                                  style: Theme.of(context).textTheme.display4),
                              color: loginLoading
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                      // FlatButton(
                      //   onPressed: () => setState(() {loginLoading = false;}),
                      //   child: Text("RESET")
                      // ),
                      Container(
                        width: 300,
                        child: Center(
                            child: GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed("/register"),
                                child: Text("Tidak punya akun? Klik Disini",
                                    style: TextStyle(color: Colors.grey)))),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _floatingButton("Facebook"),
                      SizedBox(height: 10)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
