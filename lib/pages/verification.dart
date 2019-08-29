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
  File picture;

  String _imageBase64;

  String _identityNumber;
  // TextEditingController identityNumberFocusNode

  @override
  void initState() {
    super.initState();
    globals.getNotificationCount();
    setState(() {
      isLoading = false;
    });
  }

  Future _takePicture() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 200, imageQuality: 60);

    if (imageFile != null) {
      // setState(() {
      //   isLoading = true;
      // });

      setState(() {
        picture = imageFile;
        List<int> imageBytes = imageFile.readAsBytesSync();

        String base64Image = base64Encode(imageBytes);

        _imageBase64 = base64Image;
      });
      // print(imageFile);
      // uploadFile();
    }
  }

  _save() async {
    if (picture == null) {
      globals.showDialogs("Foto KTP masih kosong", context);
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
          formData['image_base64'] = _imageBase64;

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

  @override
  Widget build(BuildContext context) {
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
                child: Container(
                  padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                  child: Center(
                    child: ListView(children: <Widget>[
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
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: picture != null
                            ? Image.file(picture, fit: BoxFit.cover)
                            : Container(),
                      ),
                      isLoading
                          ? Container()
                          : Container(
                              width: globals.mw(context),
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: FlatButton(
                                  onPressed: () =>
                                      isLoading ? null : _takePicture(),
                                  child: Text(
                                      isLoading
                                          ? "Loading"
                                          : "Ambil Foto dengan Kamera",
                                      style:
                                          Theme.of(context).textTheme.display4),
                                  color: isLoading
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)))),
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
                    ]),
                  ),
                ),
              ),
            )));
  }
}
