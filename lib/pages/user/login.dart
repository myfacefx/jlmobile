import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  FacebookLogin facebookLogin = FacebookLogin();
  
  FocusNode focusNode = FocusNode();
  
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget _floatingButton(String icon) {
    Color backgr =
        icon == "Facebook" ? Color.fromRGBO(45, 80, 155, 1) : Colors.white;

    Color clrText = icon != "Facebook" ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: FloatingActionButton.extended(
        onPressed: () {
          facebookLogin.logInWithReadPermissions(['email'])
          .then((result) {
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
          }) 
          .catchError((e) {
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
    return Center(
      child: Image.asset(
        'assets/images/jlf-back.png',
        width: globals.mw(context),
        height: globals.mh(context),
        fit: BoxFit.fill,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          Column(
            children: <Widget>[
              Container(
                height: globals.mh(context) * 0.4,
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 140),
                )
              ),
              Container(
                height: globals.mh(context) * 0.6,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        focusNode: focusNode,
                        autofocus: true,
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: "Username",
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          )
                        ),
                      )
                    ),
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        focusNode: focusNode,
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          )
                        ),
                      )
                    ),
                    Container(
                      child: FlatButton(
                        onPressed: () => Navigator.pushNamed(context, "/home"),
                        child: Text("LOG IN"),
                        color: Theme.of(context).primaryColor
                      )
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    _floatingButton("Facebook")
                  ],
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
