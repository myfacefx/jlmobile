import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jlf_mobile/services/send_wa_service.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:pin_view/pin_view.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyPinPage extends StatefulWidget {
  final String pinUser;
  final String phoneNumber;
  final bool isMatch;
  final int userId;
  const VerifyPinPage(
      {Key key,
      this.pinUser,
      @required this.phoneNumber,
      this.isMatch,
      this.userId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      _VerifyPinState(pinUser, phoneNumber, userId, isMatch);
}

class _VerifyPinState extends State<VerifyPinPage> {
  bool _isProcessing = false;
  String pinUser = "";
  String _phoneNumber;
  String _phoneNumberSubs;
  bool _isAvailable = false;
  bool _isMatch = false;
  int _userId;
  String _messageOTP;
  String _otpKey;
  Timer _timer;
  int _start;

  void initState() {
    super.initState();
    _phoneNumberSubs = _phoneNumber.substring(_phoneNumber.length - 5);

    _start = 120;
    if (_start == 120 || _start == 0) {
      _isAvailable = true;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }

  _VerifyPinState(String pinUser, String phoneNumber, int userId,
      [bool isMatch]) {
    this.pinUser = pinUser;
    this._phoneNumber = phoneNumber;
    this._isMatch = isMatch;
    this._userId = userId;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
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
        "== [JLF] ==\nJANGAN MEMBERITAHU KODE RAHASIA INI KE SIAPAPUN termasuk pihak JLF. KODE INI HANYA DIGUNAKAN DI APLIKASI JLF. KODE RAHASIA untuk VERIFIKASI OTP ANDA adalah :" +
            _otpKey +
            ". Kunjungi Kami di http://juallelangfauna.com/";

    var formData = Map<String, dynamic>();
    formData['phone'] = _phoneNumber;
    formData['message'] = _messageOTP;

    try {
      final res = await sendOTP(formData);
      if (res == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
      }
      _isProcessing = false;
    } catch (error) {
      Navigator.pop(context);
      globals.showDialogs("Internal Server Error - SOTP-01", context);
    }
  }

  _sendWhatsApp(phone, message) async {
    if (phone.isNotEmpty && message.isNotEmpty) {
      String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double mh = MediaQuery.of(context).size.height;
    double mw = MediaQuery.of(context).size.width;
    // SystemChrome.setEnabledSystemUIOverlays([]);

    Widget _imageHeader() {
      return Image.asset(
        'assets/images/jlf-blue.png',
        width: mw * 0.5,
        height: mh * 0.3,
        fit: BoxFit.fitWidth,
      );
    }

    Widget _resendOTP() {
      _isAvailable = true;
      _start = 120;
      return Container();
    }

    Widget _buildContactAdmin() {
      return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                globals.myText(text: "Butuh Bantuan?"),
                GestureDetector(
                  onTap: () {
                    String phone = "6282223304275";
                    String message =
                        "Saya pengguna dengan nomor WA $_phoneNumber mengalami kesulitan Verifikasi Data Via OTP";
                    _sendWhatsApp(phone, message);
                  },
                  child: Container(
                      height: 25,
                      child: CircleAvatar(
                          radius: 15,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child:
                                  Image.asset('assets/images/whatsapp.png')))),
                )
              ]));
    }

    Widget _buildPhoneNumberField(_phoneNumber) {
      return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          // margin: EdgeInsets.only(bottom: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                globals.myText(
                    text:
                        "Kami Akan Mengirimkan OTP ke Nomor WA Kamu Yang Berakhiran",
                    size: 20,
                    align: TextAlign.center),
                SizedBox(
                  height: 8,
                ),
                globals.myText(text: "XXXXXX-" + _phoneNumberSubs, size: 20),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _isAvailable == true
                        ? RaisedButton(
                            onPressed: () {
                              Toast.show("Mengirim OTP . . .", context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.TOP);
                              setState(() {
                                _isAvailable = false;
                                _sendOTP();
                                if (mounted) {
                                  startTimer();
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: globals.myText(
                                text: "Request OTP", color: "light", size: 15),
                            color: globals.myColor("primary"),
                          )
                        : RaisedButton(
                            onPressed: () {
                              Toast.show("Tunggu $_start detik", context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.TOP);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: globals.myText(
                                text: "Request OTP", color: "black", size: 15),
                            color: globals.myColor("grey"),
                          ),
                    SizedBox(
                      width: 8,
                    ),
                    _start != 0
                        ? globals.myText(text: "$_start" + "s")
                        : _resendOTP(),
                  ],
                )
              ]));
    }

    void _userVerificationByOTP(_userId) async {
      try {
        debugPrint(globals.user.tokenRedis);
        final res =
            await updateVerificationByOTP(_userId, globals.user.tokenRedis);
        if (res == null) {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
        }
        globals.debugPrint("content");
        _isProcessing = false;
        setState(() {
          globals.user.verificationStatus = "verified";
        });
        // globals.state = "/profile";
        Navigator.pop(context, true);
        Navigator.pop(context, true);
        // Navigator.pushNamed(context, "/profile");
        // Navigator.pushReplacementNamed(context, "/profile");
      } catch (error) {
        Navigator.pop(context, true);
        // globals.showDialogs(
        //     "Gagal Verifikasi Data, Silakan hubungi admin", context);
      }
    }

    void _verifyPin(String inputPin) async {
      try {
        if (inputPin == _otpKey) {
          Toast.show("OTP Cocok!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);

          if (_userId != null) {
            _userVerificationByOTP(_userId);
          } else {
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          }
        } else {
          globals.showDialogs("OTP anda salah, Coba lagi", context);
        }
      } catch (e) {
        Navigator.pop(context);
      }
    }

    Widget _buildInputPin() {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: PinView(
            count: 6, // describes the field number
            margin: EdgeInsets.all(5), // margin between the fields
            obscureText:
                false, // describes whether the text fields should be obscure or not, defaults to false
            style: TextStyle(
                // style for the fields
                fontSize: 19.0,
                color: Colors.black,
                fontWeight: FontWeight.w500),
            dashStyle: TextStyle(
                // dash style
                fontSize: 25.0,
                color: Colors.grey),
            // autoFocusFirstField: true,
            inputDecoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).buttonColor))),
            submit: (String pin) {
              _verifyPin(pin);
            }),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final res = await globals.willExit(context,
            contentText: "Apakah anda yakin akan membatalkan proses OTP ?");
        if (res) {
          // globals.state = "login";
          Navigator.pop(context);
          // Navigator.pushReplacementNamed(context, "/login");
        }
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    _imageHeader(),
                    _buildPhoneNumberField(_phoneNumber),
                    _buildInputPin(),
                    Text(
                      "Masukan OTP",
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    _buildContactAdmin(),
                    _buildFooter(mh, mw),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(mh, mw) {
    return Container(
      padding: EdgeInsets.fromLTRB(72, 50, 72, 50),
      alignment: Alignment.bottomCenter,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            "Powered by",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
          SizedBox(
            height: 15,
          ),
          Image.asset(
            'assets/images/jlf-blue.png',
            width: (mw / mh) * 150,
          ),
        ],
      ),
    );
  }
}
