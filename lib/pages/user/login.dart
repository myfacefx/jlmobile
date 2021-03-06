import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/user/register.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:jlf_mobile/services/version_services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  FacebookLogin facebookLogin = FacebookLogin();

  final _formKey = GlobalKey<FormState>();

  FocusNode passwordFocusNode = FocusNode();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool passwordVisibility = true;

  bool loginLoading = false;
  bool autoValidate = false;

  bool alreadyUpToDate = false;

  String _username;
  String _password;
  int membersCount;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  _getCount() {
    getUsersCount().then((onValue) {
      setState(() {
        membersCount = onValue;
      });
    }).catchError((onError) {
      globals.showDialogs(onError, context);
    });
  }

  void _checkVersion() {
    globals.debugPrint("Checking Version");
    verifyVersion(globals.version).then((onValue) async {
      if (!onValue.isUpToDate) {
        final result = await globals.showUpdate(
            onValue.url, onValue.isForceUpdate, onValue.message, context);
        if (!result) {
          _checkVersion();
        }
      } else {
        globals.debugPrint("Already Up To Date Version");
        _getCount();
      }
    }).catchError((onError) async {
      await globals.showDialogs(
          "Maaf, Server Sedang Dalam Maintenance,\nSilakan Coba Kembali Beberapa Saat Lagi",
          context);
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }

  _logIn() async {
    if (loginLoading) return;
    _formKey.currentState.save();

    if (_formKey.currentState.validate()) {
      setState(() {
        loginLoading = true;
      });

      var formData = Map<String, dynamic>();
      formData['username'] = _username;
      formData['password'] = _password;

      User loginUser = User();
      loginUser.username = _username;
      loginUser.password = _password;

      try {
        Map<String, dynamic> response = await login((loginUser.toJson()));

        if (response != null) {
          if (response['status'] == 'success') {
            // Successfully Login
            User user = userFromJson(json.encode(response['data']));

            saveLocalData('user', json.encode(response['data']));

            globals.user = user;
            globals.state = "home";

            Navigator.of(context).pop();

            Navigator.pushNamed(context, "/");
          } else {
            globals.showDialogs(response['message'], context);
            globals.debugPrint("ERR: " + response.toString());
          }
        }

        setState(() {
          loginLoading = false;
        });
      } catch (e) {
        try {
          globals.showDialogs(e.toString().split(":")[1], context);
          globals.debugPrint(e.toString());
          // globals.mailError("Login", e.toString());
        } catch (e) {
          globals.showDialogs(e.toString(), context);
        }

        setState(() {
          loginLoading = false;
        });
      }
    } else {
      setState(() {
        loginLoading = false;
        autoValidate = true;
      });
    }
  }

  _loginWithFacebook() async {
    setState(() {
      loginLoading = true;
    });

    FacebookLoginResult result = await facebookLogin.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        globals.debugPrint("####FACEBOOK OUTPUT#####");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,address,gender,location,picture.type(large).redirect(false)&access_token=${result.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        globals.debugPrint(profile.toString());

        User searchUser = User();
        searchUser.email = profile['email'];
        searchUser.facebookUserId = profile['id'];

        globals.debugPrint("FB LOGIN LOOKUP");
        globals.debugPrint(searchUser.toJson());
        List<User> users = await fbLoginSearch(searchUser.toJson());

        globals.debugPrint("####USERS TO STRING#####" + users.toString());

        if (users.length > 0) {
          globals.debugPrint("USER FOUND, login");
          // Similar email found, user registered
          saveLocalData("user", userToJson(users[0]));

          globals.user = users[0];
          globals.state = "home";

          Navigator.pushNamed(context, "/");
        } else {
          User registerUser = User();
          registerUser.email = profile['email'];
          registerUser.name = profile['name'];
          registerUser.facebookUserId = profile['id'];
          registerUser.photo = profile['picture']['data']['url'];

          globals.debugPrint("USER NOT FOUND, registering");
          // No similar email found, user will be pushed to register page

          globals.state = "register";

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      RegisterPage(user: registerUser)));
        }

        setState(() {
          loginLoading = false;
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        // globals.showDialog("Login dengan Facebook dibatalkan", context);
        setState(() {
          loginLoading = false;
        });
        throw new StateError("Cancelled by user");
        break;
      case FacebookLoginStatus.error:
        // LoginManager
        globals.showDialogs("Error: ${result.errorMessage}", context);
        facebookLogin.logOut();

        setState(() {
          loginLoading = false;
        });
        // throw new StateError(FacebookLoginStatus.error.toString());
        break;
    }
  }

  _doNothing() {
    return;
  }

  Widget _registerManual() {
    return Container(
      width: 300,
      child: Center(
          child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed("/register"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(
                      text: "Tidak punya akun? Klik ", color: "dark"),
                  globals.myText(
                      text: "di sini",
                      weight: "SB",
                      decoration: TextDecoration.underline,
                      color: "primary"),
                ],
              ))),
    );
  }

  Widget _forgetPassword() {
    return Container(
      width: 300,
      child: Center(
          child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed("/forget-password"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Reset password, Klik ", color: "dark"),
                  globals.myText(
                      text: "di sini",
                      weight: "SB",
                      decoration: TextDecoration.underline,
                      color: "primary"),
                ],
              ))),
    );
  }

  Widget _textFacebook() {
    return Container(
      width: 300,
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          globals.myText(text: "Daftar dan masuk dengan", color: "dark"),
        ],
      )),
    );
  }

  Widget _floatingButton(String icon) {
    Color backgr =
        icon == "Facebook" ? Color.fromRGBO(45, 80, 155, 1) : Colors.white;

    Color clrText = icon != "Facebook" ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: FloatingActionButton.extended(
        onPressed: () {
          !loginLoading ? _loginWithFacebook() : _doNothing();
        },
        backgroundColor: loginLoading ? Colors.grey : backgr,
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

  _exitDialog() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    // return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text("Perhatian",
    //             style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
    //             textAlign: TextAlign.center),
    //         content: Text("Keluar dari aplikasi?",
    //             style: TextStyle(color: Colors.black)),
    //         actions: <Widget>[
    //           FlatButton(
    //               child: Text("Batal",
    //                   style: TextStyle(color: Theme.of(context).primaryColor)),
    //               onPressed: () {
    //                 Navigator.of(context).pop(true);
    //               }),
    //           FlatButton(
    //               color: Theme.of(context).primaryColor,
    //               child: Text("Ya", style: TextStyle(color: Colors.white)),
    //               onPressed: () {
    //                 SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    //               })
    //         ],
    //       );
    //     });
  }

  Widget _termOfServices() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Wrap(alignment: WrapAlignment.center, children: <Widget>[
          Text("By logging in or registering, I agree to Jual Lelang Fauna's ",
              style: TextStyle(color: Colors.black, fontSize: 12)),
          GestureDetector(
            onTap: () {
              globals.showDialogs("Term of Service JLF", context);
            },
            child: Text("Terms of Service",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 12)),
          ),
          Text(" and ", style: TextStyle(color: Colors.black, fontSize: 12)),
          GestureDetector(
            onTap: () {
              globals.showDialogs("Privacy Policy JLF", context);
            },
            child: Text("Privacy Policy",
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 12)),
          ),
          Text(".", style: TextStyle(color: Colors.black, fontSize: 12))
        ]));
  }

  Widget _loginProblem() {
    return Container(
      width: 300,
      child: Center(
          child: GestureDetector(
              onTap: () {
                globals.sendWhatsApp(globals.getNohpAdmin(),
                    "Tolong di bantu min, saya mengalami susah Login");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  globals.myText(text: "Susah login? ", color: "dark"),
                  globals.myText(
                      text: "Hubungi Admin kami",
                      weight: "SB",
                      decoration: TextDecoration.underline,
                      color: "primary"),
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("open login");
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return WillPopScope(
      onWillPop: () {
        _exitDialog();
        return;
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                    height: globals.mh(context) * 0.25,
                    child: Center(
                      child: Image.asset("assets/images/jlf-blue.png",
                          height: 140),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                  child: Image.asset(
                    "assets/images/pets_login.png",
                    fit: BoxFit.fitHeight,
                    height: 200,
                    width: globals.mw(context),
                  ),
                )),
                SizedBox(
                  height: 16,
                ),
                membersCount != null
                    ? globals.myText(
                        text: "$membersCount Member Terdaftar",
                        weight: "B",
                        align: TextAlign.center)
                    : Container(),
                SizedBox(height: 8),
                Form(
                  autovalidate: autoValidate,
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Username / Phone Number masih kosong';
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
                                hintText: "Username / Phone Number",
                                labelText: "Username / Phone Number",
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
                      // _registerManual(),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      _forgetPassword(),
                      SizedBox(
                        height: 15,
                      ),
                      _textFacebook(),
                      SizedBox(
                        height: 5,
                      ),
                      _floatingButton("Facebook"),
                      SizedBox(height: 15),
                      _loginProblem(),
                      SizedBox(height: 30),
                      _termOfServices(),
                      SizedBox(height: 10),
                      globals.myText(text: "${globals.version}", size: 11),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
