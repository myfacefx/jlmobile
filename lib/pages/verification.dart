import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/user_services.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController identityNumberController = TextEditingController();

  bool isLoading = true;
  File _ktp;
  File _selfie;

  String _ktpBase64;
  String _selfieBase64;

  String _identityNumber;

  String _verificationStatus;
  // TextEditingController identityNumberFocusNode

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
    _getVerificationStatus();
    setState(() {
      isLoading = false;
    });
  }

  _getVerificationStatus() async {
    User userResponse = await get(globals.user.id);

    setState(() {
      _verificationStatus = userResponse.verificationStatus;
      globals.user.verificationStatus = userResponse.verificationStatus;
      globals.user.identityNumber = userResponse.identityNumber;
    });
  }

  Future _takeKTP() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 500, imageQuality: 60);

    if (imageFile != null) {
      setState(() {
        _ktp = imageFile;
        List<int> imageBytes = imageFile.readAsBytesSync();

        String base64Image = base64Encode(imageBytes);

        _ktpBase64 = base64Image;
      });
    }
  }
  
  Future _takeSelfie() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 500, imageQuality: 60);

    if (imageFile != null) {
      setState(() {
        _selfie = imageFile;
        List<int> imageBytes = imageFile.readAsBytesSync();

        String base64Image = base64Encode(imageBytes);

        _selfieBase64 = base64Image;
      });
    }
  }

  _save() async {
    if (_ktp == null) {
      globals.showDialogs("Foto KTP masih kosong", context);
      return false;
    }

    if (_selfie == null) {
      globals.showDialogs("Foto Selfie dengan KTP masih kosong", context);
      return false;
    }

    if (_formKey.currentState.validate()) {
      var response = await globals.confirmDialog(
          "Pastikan data yang akan dikirim sudah sesuai dan data yang sesungguh-sungguhnya",
          context);

      print(response);

      if (response) {
        setState(() {
          isLoading = true;
        });
        _formKey.currentState.save();

        User updateUser = User();
        updateUser.identityNumber = _identityNumber;
        updateUser.verificationStatus = 'pending';

        try {
          Map<String, dynamic> formData = updateUser.toJson();
          formData['ktp_base64'] = _ktpBase64;
          formData['selfie_base64'] = _selfieBase64;

          print(formData.toString());

          Map<String, dynamic> response = await updateVerification(formData, globals.user.id);

          print(response);

          if (response != null) {
            globals.user.identityNumber = updateUser.identityNumber;
            globals.user.verificationStatus = updateUser.verificationStatus;

            setState(() {});

            User user = globals.user;
            user.identityNumber = updateUser.identityNumber;
            user.verificationStatus = updateUser.verificationStatus;

            saveLocalData('user', userToJson(user));

            globals.state = "home";

            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/");
            globals.showDialogs(response['message'], context);
          } else {
            globals.showDialogs("Terjadi error, silahkan ulangi", context);
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          globals.showDialogs("Terjadi error, silahkan ulangi kembali", context);
          print(e.toString());
          globals.mailError("KTP Verification", e.toString());
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildKTP() {
    return Column(
      children: <Widget>[
        globals.myText(text: "Foto KTP", align: TextAlign.center, size: 20, weight: "B"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: _ktp != null
                            ? Image.file(_ktp, fit: BoxFit.cover)
                            : Image.asset("assets/images/error.jpeg", height: 120),
                      ),
        isLoading
          ? Container()
          : Container(
              width: globals.mw(context),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FlatButton(
                  onPressed: () =>
                      isLoading ? null : _takeKTP(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          isLoading
                              ? "Loading"
                              : "Ambil Foto KTP",
                          style:
                              Theme.of(context).textTheme.display4),
                      Icon(Icons.camera_alt, color: Colors.white)
                    ],
                  ),
                  color: isLoading
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
      ],
    );
  }

  Widget _buildSelfie() {
    return Column(
      children: <Widget>[
        globals.myText(text: "Foto Selfie dengan KTP", align: TextAlign.center, size: 20, weight: "B"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: _selfie != null
                            ? Image.file(_selfie, fit: BoxFit.cover)
                            : Image.asset("assets/images/error.jpeg", height: 120),
                      ),
        isLoading
          ? Container()
          : Container(
              width: globals.mw(context),
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: FlatButton(
                  onPressed: () =>
                      isLoading ? null : _takeSelfie(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          isLoading
                              ? "Loading"
                              : "Ambil Foto Selfie dengan KTP",
                          style:
                              Theme.of(context).textTheme.display4),
                      Icon(Icons.camera_alt, color: Colors.white)
                    ],
                  ),
                  color: isLoading
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    print(_verificationStatus != null ? _verificationStatus : "KOSONG");
    String display = 'Pending';
    String color = 'warning';
    
    if (_verificationStatus == 'verified') {
      display = "Terverifikasi";
      color = 'success';
    } else if (_verificationStatus == 'denied') {
      color = 'danger';
      display = "Pengajuan KTP Ditolak, silahkan ulangi";
    }

    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true, showNotification: false, hideNavigation: true),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: WillPopScope(
                onWillPop: () async {
                  var response = await globals.confirmDialog("Yakin ingin keluar dari aplikasi?", context);

                  if (response) {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  }
                },
                child: isLoading ? globals.isLoading() : Container(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                  child: Center(
                    child: ListView(children: <Widget>[
                      Center(
                        child: Container(
                          child: globals.myText(text: display, color: color, size: 20, align: TextAlign.center)
                        ),
                      ), 
                      globals.myText(text: _verificationStatus == 'pending' ? "Verifikasi KTP Anda sedang kami proses, nantikan segera" : _verificationStatus == 'success' ? "Selamat! Verifikasi KTP Anda telah kami terima" : "", align: TextAlign.center),
                      _verificationStatus == 'pending' || _verificationStatus == 'verified' ? FlatButton(
                        onPressed: () => Navigator.of(context).pushNamed('/'),
                        color: globals.myColor('primary'),
                        child: globals.myText(text: "Kembali ke Beranda", color: 'light')
                      ) : Container(),
                      _verificationStatus == null || _verificationStatus == 'denied' ? Column(
                        children: <Widget>[
                          globals.myText(
                              text: "Verifikasi KTP",
                              weight: "B",
                              size: 24,
                              align: TextAlign.center),
                          SizedBox(height: 8),
                          globals.myText(
                              text:
                                  "Sobat JLF, untuk memberikan rasa aman dan nyaman dalam menggunakan aplikasi JLF, kini sobat JLF diwajibkan untuk melakukan verifikasi KTP.",
                              align: TextAlign.center),
                          globals.myText(
                              text: "(Pastikan data pada KTP terlihat jelas)",
                              size: 13,
                              align: TextAlign.center),
                          Divider(),
                          _buildKTP(),
                          Divider(),
                          _buildSelfie(),
                          Form(
                              autovalidate: true,
                              key: _formKey,
                              child: Container(
                                  width: 300,
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: TextFormField(
                                    enabled: !isLoading,
                                    controller: identityNumberController,
                                    onSaved: (String value) {
                                      _identityNumber = value;
                                    },
                                    onFieldSubmitted: (String value) {
                                      _save();
                                    },
                                    validator: (value) {
                                      if (value.isEmpty || value.length != 16) {
                                        return 'Nomor KTP tidak sesuai';
                                      }
                                    },
                                    style: TextStyle(color: Colors.black),
                                    textCapitalization: TextCapitalization.words,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(13),
                                        hintText: "Nomor KTP",
                                        labelText: "16 Digit Nomor KTP",
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5))),
                                  ))),
                          Container(
                              width: globals.mw(context),
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: FlatButton(
                                  onPressed: () => isLoading ? null : _save(),
                                  child: Text(isLoading ? "Loading" : "Simpan",
                                      style: Theme.of(context).textTheme.display4),
                                  color: isLoading
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)))),
                          globals.spacePadding(),
                        ],
                      ) : Container(),
                    ]),
                  ),
                ),
              ),
            )));
  }
}
