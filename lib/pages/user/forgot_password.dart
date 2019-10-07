import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/pin_code.dart';
import 'package:jlf_mobile/services/user_services.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool _isMatch = false;

  Widget _textInputEmail() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: TextFormField(
          controller: emailController,
          textInputAction: TextInputAction.next,
          validator: (String text) {
            String ret = "---";
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (text == "" || text == null) {
              ret = "Email tidak boleh kosong";
              return ret;
            } else if (!regex.hasMatch(text)) {
              ret = 'Email tidak valid';
              return ret;
            }
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

  void _resetPassword() async {
    formKey.currentState.save();

    if (formKey.currentState.validate()) {
      try {
        _verifyByOTP();
      } catch (e) {
        Navigator.pop(context);
        globals.showDialogs(
            "Terjadi kesalahan, coba untuk hubungi admin", context);
        globals.debugPrint(e.toString());
        globals.mailError("Forgot password", e.toString());
      }
    }
  }

  void _verifyByOTP() async {
    String _phoneNumber;
    try {
      final result = await getUserByEmail(emailController.text);

      if (result == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        _isMatch = false;
      }

      if (result.phoneNumber == null) {
        await globals.showDialogs("Email Tidak Ditemukan!", context,
            isLogout: true);
      } else {
        setState(() {
          _phoneNumber = result.phoneNumber;
        });
        _awaitResultFromOTP(context, _phoneNumber);
      }
    } catch (e) {
      Navigator.pop(context);
      globals.showDialogs(
          "Terjadi kesalahan, coba untuk hubungi admin", context);
      globals.debugPrint(e.toString());
      globals.mailError("Forgot password", e.toString());
    }
  }

  void _awaitResultFromOTP(BuildContext context, _phoneNumber) async {
    final resultFromOTP = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                VerifyPinPage(phoneNumber: _phoneNumber)));
    setState(() {
      _isMatch = resultFromOTP;
    });

    if (_isMatch == true) {
      final result = await forgotPassword(emailController.text);
      Navigator.pop(context);
      if (result == 1) {
        globals.showDialogs(
            "Untuk menjaga keamanan password anda kami akan mengirimkan password baru anda, jika anda ingin mengganti silahkan login dan ganti melalui menu edit profile",
            context,
            isLogout: true);
      } else if (result == 2) {
        globals.showDialogs("Email tidak ditemukan", context);
      } else {
        globals.showDialogs(
            "Terjadi kesalahan, coba untuk hubungi admin", context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
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
                          onPressed: () => _verifyByOTP(),
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
