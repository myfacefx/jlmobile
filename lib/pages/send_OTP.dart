import 'dart:math';

import 'package:jlf_mobile/services/send_wa_service.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:quiver/async.dart';
import 'package:flutter/material.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/pages/component/drawer.dart';

class SendOTPPage extends StatefulWidget {
  final String phoneNumber;
  final int userId;
  SendOTPPage({Key key, this.phoneNumber, this.userId}) : super(key: key);
  @override
  _SendOTPPageState createState() => _SendOTPPageState(phoneNumber, userId);
}

class _SendOTPPageState extends State<SendOTPPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  int _userId;
  String _phoneNumber;
  String _phoneNumberSubs;
  bool _isPressed = false;
  String _otpKey;
  String _messageOTP;
  int _start = 120;
  int _current = 120;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _phoneNumberSubs = _phoneNumber.substring(_phoneNumber.length - 5);
  }

  _SendOTPPageState(String phoneNumber, int userId) {
    _phoneNumber = phoneNumber;
    _userId = userId;
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      sub.cancel();
    });
  }

  void generateRandomOTP() {
    var rndnumber = "";
    var rnd = new Random();
    for (var i = 0; i < 6; i++) {
      rndnumber = rndnumber + rnd.nextInt(9).toString();
    }
    _otpKey = rndnumber;
  }

  _sendOTP() async {
    generateRandomOTP();
    _messageOTP =
        "<#> DON'T SHARE THIS WITH ANYONE.Your SECRET OTP CODE :" + _otpKey;

    var formData = Map<String, dynamic>();
    formData['phone'] = _phoneNumber;
    formData['message'] = _messageOTP;

    try {
      final res = await sendOTP(formData, globals.user.tokenRedis);
      if (res == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
      }
    } catch (error) {
      Navigator.pop(context);
      globals.showDialogs(e.toString(), context);
    }
  }

  _verifyByOTP(_userId) async {
    try {
      final res =
          await updateVerificationByOTP(_userId, globals.user.tokenRedis);
      if (res == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
      }
      SnackBar(content: Text('Yay! Sudah Terverifikasi'));
    } catch (error) {
      Navigator.pop(context);
      globals.showDialogs(e.toString(), context);
    }
  }

  Widget _buildPhoneNumberField(_phoneNumber) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        margin: EdgeInsets.only(bottom: 16),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              globals.myText(
                  text:
                      "Kami Akan Mengirimkan OTP ke Nomor WA Kamu Yang Berakhiran",
                  size: 20),
              SizedBox(
                height: 8,
              ),
              globals.myText(text: "XXXXXX-" + _phoneNumberSubs, size: 20),
              SizedBox(
                height: 8,
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    _isPressed = true;
                    _sendOTP();
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: globals.myText(
                    text: "Request OTP", color: "light", size: 15),
                color: globals.myColor("primary"),
              )
            ]));
  }

  Widget _buildFormOTP() {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        margin: EdgeInsets.only(bottom: 16),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Masukan OTP'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  setState(() {
                    _controller.text = value;
                  });
                },
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {
                          startTimer();
                          _controller.text == _otpKey
                              ? _verifyByOTP(_userId)
                              : globals.showDialogs("OTP Salah", context);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: globals.myText(
                            text: "Kirim", color: "light", size: 15),
                        color: globals.myColor("primary"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      globals.myText(text: "$_current" + "s"),
                      SizedBox(
                        width: 8,
                      ),
                      _current == 0
                          ? RaisedButton(
                              onPressed: () {
                                setState(() {
                                  _sendOTP();
                                });
                                // if (_formKey.currentState.validate()) {
                                //   Scaffold.of(context).showSnackBar(
                                //       SnackBar(content: Text('Processing Data')));
                                // }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: globals.myText(
                                  text: "Resend OTP", color: "light", size: 15),
                              color: globals.myColor("primary"),
                            )
                          : Container(),
                    ],
                  )),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
                child: ListView(physics: ScrollPhysics(), children: <Widget>[
              _buildPhoneNumberField(_phoneNumberSubs),
              _isPressed ? _buildFormOTP() : Container()
            ]))));
  }
}
