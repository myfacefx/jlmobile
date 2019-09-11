import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget _textInputEmail() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          validator: (String text) {
            String ret = "";
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (text == "" || text == null) {
              ret = "Email tidak boleh kosong";
            }
            if (!regex.hasMatch(text)) {
              ret = 'Email tidak valid';
            }
            return ret;
          },
          onFieldSubmitted: (String value) {
            _resetPassword();
          },
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Email",
              labelText: "Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
        ));
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

  Widget _logo() {
    return Container(
        height: globals.mh(context) * 0.4,
        child: Center(
          child: Image.asset("assets/images/logo.png", height: 140),
        ));
  }

  void _resetPassword() {
    formKey.currentState.save();

    if (formKey.currentState.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Stack(
            children: <Widget>[
              _buildBackground(),
              Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    _logo(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: globals.mh(context) * 0.1,
                        ),
                        globals.myText(
                            text: "Reset Password", weight: "B", size: 16),
                        _textInputEmail(),
                        FlatButton(
                          color: globals.myColor("primary"),
                          child: globals.myText(text: "Kirim", color: "light"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () => _resetPassword(),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
