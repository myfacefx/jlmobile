import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jlf_mobile/globals.dart' as globals;
import 'package:jlf_mobile/models/province.dart';
import 'package:jlf_mobile/models/regency.dart';
import 'package:jlf_mobile/models/user.dart';
import 'package:jlf_mobile/services/province_services.dart';
import 'package:jlf_mobile/services/regency_services.dart';
import 'package:jlf_mobile/services/user_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  bool autoValidate = false;
  bool passwordVisibility = true;
  bool confirmPasswordVisibility = true;

  bool registerLoading = false;
  bool photoUploading = false;
  bool regencyLoading = false;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  int _id;
  String _name;
  String _description;
  String _password;
  String _phoneNumber;
  Province _province;
  Regency _regency;

  List<Province> provinces = List<Province>();
  List<Regency> regencies = List<Regency>();

  File image;

  @override
  void initState() {
    super.initState();
    requestPermission();

    if (globals.user != null) {
      _name = globals.user.name;
      _description = globals.user.description;
      _id = globals.user.id;
      _phoneNumber = globals.user.phoneNumber;
      _regency = globals.user.regency;
      _province = globals.user.province;
    } else {
      Navigator.of(context).pop();
    }
    globals.getNotificationCount();

    getProvinces().then((value) {
      provinces = value;
      provinces.forEach((province) {
        if (province.id == globals.user.regency.provinceId) {
          setState(() {
            _province = province;
          });
        }
      });
      setState(() {
        this.registerLoading = false;
      });
    });

    getRegenciesByProvinceId(globals.user.regency.provinceId).then((onValue) {
      setState(() {
        regencies = onValue;
        regencies.forEach((regency) {
          if (regency.id == globals.user.regency.id) {
            setState(() {
              _regency = regency;
            });
          }
        });

        this.regencyLoading = false;
      });
    });
    //_updateRegencies(_regency.provinceId);
  }

  void requestPermission() async {
    print("Checking Permission storage");
    PermissionStatus permissionStorage = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    PermissionStatus permissionCamera =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    if (permissionStorage != PermissionStatus.granted &&
        permissionCamera != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions(
          [PermissionGroup.storage, PermissionGroup.camera]);
      requestPermission();
    }
  }

  _updateRegencies() {
    regencies = List<Regency>();
    _regency = null;
    this.regencyLoading = true;
    getRegenciesByProvinceId(_province.id).then((onValue) {
      setState(() {
        regencies = onValue;
        this.regencyLoading = false;
      });
    });
  }

  void _register() async {
    if (registerLoading) return;

    if (_formKey.currentState.validate()) {
      setState(() {
        registerLoading = true;
      });

      _formKey.currentState.save();

      User updateUser = User();
      updateUser.name = _name;
      updateUser.description = _description;
      updateUser.regencyId = _regency.id;
      updateUser.phoneNumber = _phoneNumber;

      try {
        String result =
            await updateUserLogin(updateUser.toJson(), _id, globals.user.tokenRedis);

        if (result != null) {
          globals.user.name = _name;
          globals.user.description = _description;
          globals.user.regencyId = _regency.id;
          globals.user.regency.id = _regency.id;
          globals.user.regency.name = _regency.name;
          globals.user.regency.provinceId = _province.id;
          globals.user.province.id = _province.id;
          globals.user.province.name = _province.name;
          globals.user.phoneNumber = _phoneNumber;

          setState(() {});

          Navigator.of(context).pop();
          globals.showDialogs(result, context);
        } else {
          await globals.showDialogs(
              "Session anda telah berakhir, Silakan melakukan login ulang",
              context,
              isLogout: true);
          return;
        }
      } catch (e) {
        globals.showDialogs("Terjadi error, silahkan ulangi", context);
        globals.mailError("Update profile", e.toString());
        setState(() {
          registerLoading = false;
          autoValidate = true;
        });
      }
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  Widget _fullname() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _name,
          onSaved: (String value) {
            _name = value;
          },
          onFieldSubmitted: (String value) {
            if (value.length > 0) {
              FocusScope.of(context).requestFocus(usernameFocusNode);
            }
          },
          style: TextStyle(color: Colors.black),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Nama Pengguna",
              labelText: "Nama Pengguna",
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
        ));
  }

  Widget _descriptionInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _description,
          focusNode: usernameFocusNode,
          onSaved: (String value) {
            _description = value;
          },
          onFieldSubmitted: (String value) {
            if (value.length > 0) {
              FocusScope.of(context).requestFocus(passwordFocusNode);
            }
          },
          validator: (value) {
            if (value.isEmpty || value.length < 5 || value.length > 100) {
              return 'Deskripsi panjang 5 hingga 100 huruf';
            }
          },
          style: TextStyle(color: Colors.black),
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Deskripsi",
              labelText: "Deskripsi",
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
        ));
  }

  Widget _provinceInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: DropdownButtonFormField<Province>(
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(13),
              hintText: "Provinsi",
              labelText: "Provinsi"),
          value: _province,
          validator: (province) {
            if (province == null) {
              return 'Silahkan pilih provinsi';
            }
          },
          onChanged: (Province province) {
            setState(() {
              _province = province;
            });
            _updateRegencies();
            // FocusScope.of(context)
            //   .requestFocus(regencyFocusNode);
          },
          items: provinces.map((Province province) {
            return DropdownMenuItem<Province>(
                value: province,
                child:
                    Text(province.name, style: TextStyle(color: Colors.black)));
          }).toList(),
        ));
  }

  Widget _regencyInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: DropdownButtonFormField<Regency>(
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(13),
              hintText: "Kota/Kabupaten",
              labelText: "Kota/Kabupaten"),
          onChanged: (Regency regency) {
            setState(() {
              _regency = regency;
            });
          },
          value: _regency,
          validator: (regency) {
            if (regency == null) {
              return 'Silahkan pilih wilayah kota/kabupaten';
            }
          },
          items: regencies.map((Regency regency) {
            return DropdownMenuItem<Regency>(
                value: regency,
                child: Text(
                  regency.name,
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ));
          }).toList(),
        ));
  }

  Future _chooseProfilePicture() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        photoUploading = true;
      });
      // print(imageFile);
      _cropImage(imageFile);
      // uploadFile();
    }
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 150,
      maxHeight: 150,
    );

    if (croppedFile != null) _uploadPhoto(croppedFile);
  }

  String _randomDigits(int count) {
    var rndnumber = '';
    var rnd = new math.Random();
    for (var i = 0; i < count; i++) {
      rndnumber = rndnumber + rnd.nextInt(9).toString();
    }
    return rndnumber;
  }

  Future<Null> _uploadPhoto(File imageFile) async {
    List<int> imageBytes = imageFile.readAsBytesSync();

    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> formData = Map<String, dynamic>();
    formData['image_base64'] = base64Image;

    String newFileName = globals.user.id.toString() + "-" + _randomDigits(3);
    formData['file_name'] = newFileName;

    try {
      final res = await updateProfilePicture(
          formData, globals.user.id, globals.user.tokenRedis);
      if (res == null) {
        await globals.showDialogs(
            "Session anda telah berakhir, Silakan melakukan login ulang",
            context,
            isLogout: true);
        return;
      }
      setState(() {
        globals.user.photo =
            globals.getBaseUrl() + "/images/profile_pictures/$newFileName.jpg";
      });

      globals.showDialogs("Foto berhasil diubah", context);

      print("Success update foto");
      setState(() {
        photoUploading = false;
      });
    } catch (error) {
      globals.showDialogs(
          "Gagal mengunggah foto, silahkan coba kembali", context);
      print(error);
      globals.mailError("Update image profile", error.toString());
      setState(() {
        photoUploading = false;
      });
    }
  }

  Widget _profilePictureInput() {
    return Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
            height: 150,
            child: CircleAvatar(
                radius: 100,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: globals.user != null && globals.user.photo != null
                        ? FadeInImage.assetNetwork(
                            image: image != null ? image : globals.user.photo,
                            placeholder: 'assets/images/loading.gif',
                            fit: BoxFit.cover)
                        : Image.asset('assets/images/account.png')))),
        Container(
            width: 300,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: FlatButton(
                onPressed: () =>
                    photoUploading ? null : _chooseProfilePicture(),
                child: globals.myText(
                    text: photoUploading
                        ? "Mengunggah Foto... "
                        : "Ganti Foto Profil",
                    color: "light"),
                color: registerLoading || photoUploading
                    ? Colors.grey
                    : Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
      ],
    );
  }

  Widget _phoneNumberInput() {
    return Container(
        width: 300,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TextFormField(
          initialValue: _phoneNumber,
          onSaved: (String value) {
            _phoneNumber = value;
          },
          validator: (value) {
            if (value.isEmpty || value.length < 10 || value.length > 13) {
              return 'Silahkan masukkan digit yang sesuai 10-13 digit';
            }
          },
          keyboardType: TextInputType.number,
          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(13),
              hintText: "Format 08xx",
              labelText: "Nomor Handphone (WA)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: globals.appBar(_scaffoldKey, context, isSubMenu: true),
        body: Scaffold(
            body: Stack(children: <Widget>[
          ListView(children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 20, bottom: 7),
                child: Text("Ubah Profil",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 23))),
            Form(
              autovalidate: autoValidate,
              key: _formKey,
              child: Column(children: <Widget>[
                _profilePictureInput(),
                _fullname(),
                _descriptionInput(),
                _provinceInput(),
                regencyLoading ? globals.isLoading() : _regencyInput(),
                _phoneNumberInput(),
                Container(
                    width: 300,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: FlatButton(
                        onPressed: () => registerLoading ? null : _register(),
                        child: Text(
                            !registerLoading
                                ? "Perbaharui Profil"
                                : "Mohon Tunggu",
                            style: Theme.of(context).textTheme.display4),
                        color: registerLoading
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))))
              ]),
            ),
          ])
        ])),
      ),
    );
  }
}
