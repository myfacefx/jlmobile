import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/pages/component/drawer.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _requestPermission();
    _getVerificationStatus();
  }

  void _requestPermission() async {
    print("Checking Permission storage + camera");
    PermissionStatus permissionStorage = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    PermissionStatus permissionCamera =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    if (permissionStorage != PermissionStatus.granted &&
        permissionCamera != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions(
          [PermissionGroup.storage, PermissionGroup.camera]);
      _requestPermission();
    }
  }

  _getVerificationStatus() async {
    User userResponse = await get(globals.user.id);

    setState(() {
      _verificationStatus = userResponse.verificationStatus;
      globals.user.verificationStatus = userResponse.verificationStatus;
      globals.user.identityNumber = userResponse.identityNumber;
      isLoading = false;
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

          Map<String, dynamic> response =
              await updateVerification(formData, globals.user.id);

          print(response);

          if (response != null) {
            globals.user.identityNumber = updateUser.identityNumber;
            globals.user.verificationStatus = updateUser.verificationStatus;

            User user = globals.user;
            user.identityNumber = updateUser.identityNumber;
            user.verificationStatus = updateUser.verificationStatus;

            saveLocalData('user', userToJson(user));

            globals.state = "home";

            setState(() {});

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
          // globals.showDialogs(
          //   "Terjadi error, silahkan ulangi kembali", context);
          // print(e.toString());
          // globals.mailError("KTP Verification", e.toString());

          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/");

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
        globals.myText(
            text: "Foto KTP", align: TextAlign.center, size: 20, weight: "B"),
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
                    onPressed: () => isLoading ? null : _takeKTP(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(isLoading ? "Loading" : "Ambil Foto KTP",
                            style: Theme.of(context).textTheme.display4),
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
        globals.myText(
            text: "Foto Selfie dengan KTP",
            align: TextAlign.center,
            size: 20,
            weight: "B"),
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
                    onPressed: () => isLoading ? null : _takeSelfie(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            isLoading
                                ? "Loading"
                                : "Ambil Foto Selfie dengan KTP",
                            style: Theme.of(context).textTheme.display4),
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

  _sendWhatsApp(phone, message) async {
    if (phone.isNotEmpty && message.isNotEmpty) {
      String url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_verificationStatus != null ? _verificationStatus : "KOSONG");
    String display = 'Verifikasi Pending';
    String color = 'warning';

    if (_verificationStatus == null) {
      display = '';
    } else if (_verificationStatus == 'verified') {
      display = "Verifikasi Sukses";
      color = 'success';
    } else if (_verificationStatus == 'denied') {
      color = 'danger';
      display = "Verifkasi KTP Ditolak, silahkan ulangi";
    }

    return Scaffold(
        appBar: globals.appBar(_scaffoldKey, context,
            isSubMenu: true, showNotification: false, hideNavigation: true),
        body: Scaffold(
            key: _scaffoldKey,
            drawer: drawer(context),
            body: SafeArea(
              child: WillPopScope(
                onWillPop: () async {
                  var response = await globals.confirmDialog(
                      "Yakin ingin keluar dari aplikasi?", context);

                  if (response) {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  }
                },
                child: isLoading
                    ? globals.isLoading()
                    : Container(
                        padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                        child: Center(
                          child: ListView(children: <Widget>[
                            _verificationStatus != null
                                ? Column(
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                            child: globals.myText(
                                                text: display,
                                                color: color,
                                                size: 20,
                                                align: TextAlign.center)),
                                      ),
                                      globals.myText(
                                          text: _verificationStatus == 'pending'
                                              ? "Verifikasi KTP Anda sedang kami proses, silahkan tunggu 1x24 jam"
                                              : _verificationStatus ==
                                                      'verified'
                                                  ? "Selamat! Verifikasi KTP Anda telah berhasil, silahkan menggunakan seluruh layanan pada JLF"
                                                  : "",
                                          align: TextAlign.center),
                                    ],
                                  )
                                : Container(),
                            _verificationStatus == 'pending' ||
                                    _verificationStatus == 'verified'
                                ? FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pushNamed('/'),
                                    color: globals.myColor('primary'),
                                    child: globals.myText(
                                        text: "Kembali ke Beranda",
                                        color: 'light'))
                                : Container(),
                            _verificationStatus == null ||
                                    _verificationStatus == 'denied'
                                ? Column(
                                    children: <Widget>[
                                      globals.myText(
                                          text: "Verifikasi KTP",
                                          weight: "B",
                                          size: 24,
                                          align: TextAlign.center),
                                      SizedBox(height: 8),
                                      globals.myText(
                                          text:
                                              "Hai sobat JLF, dalam rangka meningkatkan keamanan serta membantu membangun rasa percaya maka pihak kami mewajibkan verifikasi KTP.",
                                          align: TextAlign.center),
                                      globals.myText(
                                          text:
                                              "(Pastikan data pada KTP terlihat jelas)",
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
                                              width: globals.mw(context),
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 10),
                                              child: TextFormField(
                                                enabled: !isLoading,
                                                controller:
                                                    identityNumberController,
                                                onSaved: (String value) {
                                                  _identityNumber = value;
                                                },
                                                onFieldSubmitted:
                                                    (String value) {
                                                  _save();
                                                },
                                                validator: (value) {
                                                  if (value.isEmpty ||
                                                      value.length != 16) {
                                                    return 'Nomor KTP tidak sesuai';
                                                  }
                                                },
                                                style: TextStyle(
                                                    color: Colors.black),
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(13),
                                                    hintText: "Nomor KTP",
                                                    labelText:
                                                        "16 Digit Nomor KTP",
                                                    fillColor: Colors.white,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5))),
                                              ))),
                                      Container(
                                          width: globals.mw(context),
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: FlatButton(
                                              onPressed: () =>
                                                  isLoading ? null : _save(),
                                              child: Text(
                                                  isLoading
                                                      ? "Loading"
                                                      : "Simpan",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .display4),
                                              color: isLoading
                                                  ? Colors.grey
                                                  : Theme.of(context)
                                                      .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)))),
                                      globals.spacePadding(),
                                    ],
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    globals.myText(
                                        text:
                                            "Terjadi Error? Tidak memiliki KTP? Atau butuh bantuan lainnya?",
                                        weight: "B",
                                        color: "danger",
                                        align: TextAlign.center),
                                    GestureDetector(
                                        onTap: () {
                                          String phone = "6282223304275";
                                          String message =
                                              "Min,%20tolong%20bantu%20verifikasi%saya%20please%20(ID #${globals.user.id})";
                                          _sendWhatsApp(phone, message);
                                        },
                                        child: globals.myText(
                                            text: "Klik disini untuk WA Admin",
                                            weight: "B",
                                            color: "primary",
                                            align: TextAlign.center))
                                  ]),
                            )
                          ]),
                        ),
                      ),
              ),
            )));
  }
}
